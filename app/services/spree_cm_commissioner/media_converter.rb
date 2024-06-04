require 'aws-sdk-mediaconvert'

module SpreeCmCommissioner
  class MediaConverter
    attr_reader :input_s3_uri_file, :output_s3_uri_path, :allow_hd

    # input_s3_uri_file: s3://production-cm/media-convert/startwar.mp4
    # output_s3_uri_path: s3://production-cm/media-convert-output
    def initialize(input_s3_uri_file, output_s3_uri_path, allow_hd: false)
      @input_s3_uri_file = input_s3_uri_file
      @output_s3_uri_path = output_s3_uri_path
      @allow_hd = allow_hd

      @client = Aws::MediaConvert::Client.new(
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
        region: ENV.fetch('AWS_REGION')
      )
    end

    def create_job
      # debugger
      @client.create_job(job_options)
    end

    def job_options
      {
        role: arn_role,
        settings: settings
      }
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
          output_group_hls,
          output_group_dash
        ]
      }

      @settings
    end

    def output_group_hls
      # hls config
      {
        name: 'HLS Group',
        output_group_settings: {
          type: 'HLS_GROUP_SETTINGS',
          hls_group_settings: {
            destination: "#{output_s3_uri_path}/hls/",
            segment_length: 10,
            min_segment_length: 0,
            segment_control: 'SEGMENTED_FILES'
          }
        },
        outputs: config_output_hlses
      }
    end

    # protocol either: 'HLS' or DASH
    def config_outputs(protocol)
      result = [
        create_output(protocol, :low),
        create_output(protocol, :standard),
        create_output(protocol, :medium)
      ]
      result << reate_output(protocol, :high) if allow_hd
      result
    end

    def config_output_dashs
      config_outputs('DASH')
    end

    def config_output_hlses
      config_outputs('HLS')
    end

    def output_group_dash
      # dash config
      {
        name: 'DASH ISO Group',
        output_group_settings: {
          type: 'DASH_ISO_GROUP_SETTINGS',
          dash_iso_group_settings: {
            destination: "#{output_s3_uri_path}/dash/",
            segment_length: 10,
            fragment_length: 4,
            min_buffer_time: 1,
            segment_control: 'SEGMENTED_FILES'
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

      name_modifier = resolution.gsub('x', '_')

      (width, height) = resolution.split('x').map(&:to_i)

      video_description = {
        width: width,
        height: height,
        codec_settings: {
          codec: 'H_264',
          h264_settings: {
            # rate_control_mode: 'CBR',
            # Use QVBR (Quality-Defined Variable Bitrate) to maintain consistent quality.
            rate_control_mode: 'QVBR',
            # bitrate: bitrate,
            max_bitrate: bitrate,
            scene_change_detect: 'ENABLED',
            quality_tuning_level: 'SINGLE_PASS'
            # qvbr_settings: {
            #   max_average_bitrate: 1,
            #   qvbr_quality_level: 1,
            #   qvbr_quality_level_fine_tune: 1.0
            # }
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
