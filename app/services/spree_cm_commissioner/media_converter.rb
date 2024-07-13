require 'aws-sdk-mediaconvert'

module SpreeCmCommissioner
  class MediaConverter
    attr_reader :input_s3_uri_file, :output_s3_uri_path, :allow_hd, :framerate

    # framerate
    FR_CINEMATIC = 24
    FR_TVSHOW = 30
    FR_ONLINE_VDO = 30
    FR_SPORT = 60
    FR_GAMING = 60

    # 'GOP_MULTIPLE' or 'EXACT'
    # GOP: This setting aligns segment boundaries with GOP boundaries. This can result in segments that are slightly longer
    # or shorter than the specified segment_length. Better Compression and Quality:
    # EXACT: this setting ensures that segments are exactly the length specified in the segment_length parameter. This may
    # result in a less efficient use of the GOP (Group of Pictures). EXACT for Strict Compliance
    SEGMENT_LENGTH_CONTROL = 'GOP_MULTIPLE'.freeze

    # HLS and DASH: in complex scenes or rapid changes, some segments might end up being much shorter than SEGMENT_LENGTH seconds
    # but can not be less than MIN_SEGMENT_LENGTH
    SEGMENT_LENGTH = 6

    # DASH: This allows for further subdivision of segments into smaller pieces, called fragments, which can be useful
    # for finer control over playback and buffering. There will be two fragments SEGMENT_LENGTH/FRAGMENT_LENGTH
    # HLS: Segment is the smallest and self-contained media in MPEG-2 Transport Stream (TS)
    FRAGMENT_LENGTH = 3

    # HLS: to prevent the actual segment_length to be less than this value
    # which can help avoid very short segments that might be inefficient for streaming.
    MIN_SEGMENT_LENGTH = 3

    # DASH:The player will buffer more content before starting playback, leading to more stable playback with fewer
    # interruptions, but at the cost of longer startup times
    # HLS: Auto control by player and MIN_SEGMENT_LENGTH is needed instead.
    SEGMENT_BUFFER_COUNT = 2

    # input_s3_uri_file: s3://production-cm/media-convert/startwar.mp4
    # output_s3_uri_path: s3://production-cm/media-convert-output
    def initialize(input_s3_uri_file, output_s3_uri_path, allow_hd: false, framerate: FR_CINEMATIC)
      @input_s3_uri_file = input_s3_uri_file
      @output_s3_uri_path = output_s3_uri_path
      @allow_hd = allow_hd
      @framerate = framerate

      @client = Aws::MediaConvert::Client.new(
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
        region: ENV.fetch('AWS_REGION')
      )
    end

    def output_sub_dir_name
      return @output_sub_dir_name if defined?(@output_sub_dir_name)

      file_name = input_s3_uri_file.split('/').last
      names = file_name.split('.')
      return names.first if names.count == 1

      @output_sub_dir_name = names[0..-2].join('-')
      @output_sub_dir_name
    end

    def create_job
      p job_options.to_json
      @client.create_job(job_options)
    end

    # role: mediaconvert_role_arn,
    # settings: job_settings,
    # user_metadata: {
    #   "Customer": "ExampleCustomer"
    # },
    # queue: "Default",
    # status_update_interval: "SECONDS_60",
    # priority: 0,
    # hop_destinations: [],
    # correlation_id: "example-correlation-id",
    # job_template: "",
    # notifications: {
    #   "Progressing": {
    #     "Sns": sns_topic_arn
    #   },
    #   "Complete": {
    #     "Sns": sns_topic_arn
    #   },
    #   "Error": {
    #     "Sns": sns_topic_arn
    #   },
    #   "Warning": {
    #     "Sns": sns_topic_arn
    #   }
    # }

    def job_options
      {
        role: arn_role,
        settings: settings,
        # sns
        # status_update_interval: 'SECONDS_60',
        status_update_interval: '60',
        notifications: {
          Progressing: {
            Sns: sns_topic_arn
          },
          Complete: {
            Sns: sns_topic_arn
          },
          Error: {
            Sns: sns_topic_arn
          },
          Warning: {
            Sns: sns_topic_arn
          }
        }
      }
    end

    def sns_topic_arn
      ENV.fetch('AWS_MEDIA_CONVERT_TOPIC')
    end

    def arn_role
      # 'arn:aws:iam::123456789012:role/MediaConvert_Default_Role'
      ENV.fetch('AWS_MEDIA_CONVERT_ROLE')
    end

    def settings
      return @settings if defined?(@settings)

      @settings = {
        inputs: [
          {
            file_input: input_s3_uri_file,
            audio_selectors: {
              'Audio Selector 1' => {
                default_selection: 'DEFAULT'
              }
            },
            video_selector: {},
            timecode_source: 'ZEROBASED'
          }
        ],
        output_groups: [
          output_group_dash,
          output_group_hls
        ]
      }

      @settings
    end

    def output_group_hls
      # hls config
      {
        name: 'HLSGroup',
        output_group_settings: {
          type: 'HLS_GROUP_SETTINGS',
          hls_group_settings: {
            destination: "#{output_s3_uri_path}/hls/#{output_sub_dir_name}/",
            segment_length_control: SEGMENT_LENGTH_CONTROL,
            segment_control: 'SEGMENTED_FILES',
            segment_length: SEGMENT_LENGTH,
            # in HLS, the buffering behavior is managed by the player
            # min_buffer_time: SEGMENT_LENGTH * SEGMENT_BUFFER_COUNT
            min_segment_length: MIN_SEGMENT_LENGTH
          }
        },
        outputs: config_output_hlses
      }
    end

    # protocol either: 'HLS' or DASH
    def config_outputs(protocol)
      result = []
      result << reate_output(protocol, :high) if allow_hd

      result.push(
        create_output(protocol, :medium),
        create_output(protocol, :standard),
        create_output(protocol, :low)
      )
    end

    def config_output_dashs
      config_outputs('DASH')
    end

    def config_output_hlses
      config_outputs('HLS')
    end

    def output_group_dash
      # dash config
      min_buffer_time = SEGMENT_LENGTH * SEGMENT_BUFFER_COUNT
      {
        name: 'DASHGroup',
        output_group_settings: {
          type: 'DASH_ISO_GROUP_SETTINGS',
          dash_iso_group_settings: {
            destination: "#{output_s3_uri_path}/dash/#{output_sub_dir_name}/",
            segment_length_control: SEGMENT_LENGTH_CONTROL,
            segment_length: SEGMENT_LENGTH,
            segment_control: 'SEGMENTED_FILES',
            min_buffer_time: min_buffer_time,
            fragment_length: FRAGMENT_LENGTH
          }
        },
        outputs: config_output_dashs
      }
    end

    # 1080p (1920x1080) - High quality
    # 720p (1280x720) - Medium quality
    # 480p (854x480) - Standard quality
    # 360p (640x360) - Low quality
    # 240p (426x240) - Very low quality
    def video_qualities
      @video_qualities ||= {
        high: { resolution: '1920x1080', bitrate: 4500..6000, framerate: [24, 30, 60], audio_rate: 128 },
        medium: { resolution: '1280x720', bitrate: 2500..3500, framerate: [24, 30, 60], audio_rate: 128 },
        standard: { resolution: '854x480', bitrate: 1000..1500, framerate: [24, 30], audio_rate: 128 },
        low: { resolution: '640x360', bitrate: 500..1000, framerate: [24, 30], audio_rate: 96 },
        bottom: { resolution: '426x240', bitrate: 300..700, framerate: [24, 30], audio_rate: 64 }
      }
    end

    def create_output(group_type, video_quality_type)
      video_quality = video_qualities[video_quality_type]
      resolution = video_quality[:resolution]
      bitrate = video_quality[:bitrate].first * 1_000

      # max_bitrate = video_quality[:bitrate].last * 1_000
      audio_bitrate = video_quality[:audio_rate] * 1_000
      name_modifier = "-#{resolution.gsub('x', '_')}"

      (width, height) = resolution.split('x').map(&:to_i)

      video_description = {
        width: width,
        height: height,
        codec_settings: {
          codec: 'H_264',
          h264_settings: {
            # Use constant bit rate(CBR) for smooth playback and player compatibility.
            rate_control_mode: 'CBR',
            bitrate: bitrate,
            # Use QVBR (Quality-Defined Variable Bitrate) to maintain consistent quality.
            # rate_control_mode: 'QVBR',
            # max_bitrate: bitrate,
            scene_change_detect: 'ENABLED',
            quality_tuning_level: 'SINGLE_PASS',

            framerate_numerator: framerate,
            framerate_denominator: 1
          }
        }
      }

      audio_description = {
        audio_type_control: 'FOLLOW_INPUT',
        codec_settings: {
          codec: 'AAC',
          aac_settings: {
            bitrate: audio_bitrate,
            coding_mode: 'CODING_MODE_2_0',
            sample_rate: 48_000
          }
        }
      }

      # DEFAULT TO Dash
      container_settings = {
        container: 'MPD',
        mpd_settings: {}
      }

      if group_type == 'HLS'
        container_settings = {
          container: 'M3U8',
          m3u_8_settings: {}
        }
      end

      {
        name_modifier: name_modifier,
        container_settings: container_settings,
        video_description: video_description,
        audio_descriptions: [audio_description]
      }
    end
  end
end
