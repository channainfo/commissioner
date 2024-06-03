require 'aws-sdk-mediaconvert'

module SpreeCmCommissioner
  class MediaConverter
    attr_reader :input_s3_uri_file, :output_s3_uri_path

    # input_s3_uri_file: s3://production-cm/media-convert/startwar.mp4
    # output_s3_uri_path: s3://production-cm/media-convert-output
    def initialize(input_s3_uri_file, output_s3_uri_path)
      @input_s3_uri_file = input_s3_uri_file
      @output_s3_uri_path = output_s3_uri_path

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
          # output_file,
          output_hls,
          output_dash
        ]
      }

      # @settings.deep_transform_keys! do |key|
      #   p "key: #{key} / #{key.class}"
      #   key.to_s.underscore.to_sym
      # end

      # p @settings

      @settings
    end

    def output_hls
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
        outputs: [
          create_output('HLS', '1280x720', 5_000_000),
          create_output('HLS', '854x480', 3_000_000),
          create_output('HLS', '640x360', 1_500_000)
        ]
      }
    end

    def output_dash
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
        outputs: [
          create_output('DASH', '1280x720', 5_000_000),
          create_output('DASH', '854x480', 3_000_000),
          create_output('DASH', '640x360', 1_500_000)
        ]
      }
    end

    def output_file
      # file config
      {
        name: 'File Group',
        output_group_settings: {
          type: 'FILE_GROUP_SETTINGS',
          file_group_settings: {
            destination: "#{output_s3_uri_path}/file"
          }
        },
        outputs: [
          {
            container_settings: {
              container: 'MP4',
              mp_4_settings: {}
            },
            video_description: {
              codec_settings: {
                codec: 'H_264',
                h264_settings: {
                  rate_control_mode: 'QVBR',
                  max_bitrate: 2048,
                  scene_change_detect: 'TRANSITION_DETECTION',
                  quality_tuning_level: 'SINGLE_PASS_HQ'
                }
              }
            },
            audio_descriptions: [
              {
                audio_type_control: 'FOLLOW_INPUT',
                codec_settings: {
                  codec: 'AAC',
                  aac_settings: {
                    bitrate: 96_000,
                    coding_mode: 'CODING_MODE_2_0',
                    sample_rate: 48_000
                  }
                }
              }
            ]
          }
        ]
      }
    end

    def create_output(group_type, resolution, bitrate)
      name_modifier = resolution.gsub('x', '_')

      (width, height) = resolution.split('x').map(&:to_i)

      video_description = {
        width: width,
        height: height,
        codec_settings: {
          codec: 'H_264',
          h264_settings: {
            rate_control_mode: 'CBR',
            bitrate: bitrate,
            scene_change_detect: 'ENABLED',
            quality_tuning_level: 'SINGLE_PASS'

            # afd_signaling: 'NONE',
            # fixed_afd: 'AFD_0000',
            # color_metadata: 'INSERT'
          }
        }
      }

      audio_description = {
        audio_type_control: 'FOLLOW_INPUT',
        codec_settings: {
          codec: 'AAC',
          aac_settings: {
            bitrate: 96_000,
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
