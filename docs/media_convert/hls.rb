{
  inputs: [
    {
      file_input: input_s3_url,
      audio_selectors: {
        'Audio Selector 1' => {
          default_selection: 'DEFAULT'
        }
      },
      video_selector: {},
      timecode_source: 'ZEROBASED',
      filter_enable: 'AUTO',
      filter_strength: 0,
      deblock_filter: 'DISABLED',
      denoise_filter: 'DISABLED',
      psi_control: 'USE_PSI',
      image_inserter: {},
      timecode_insertion: 'DISABLED'
    }
  ],
  output_groups: [
    {
      name: 'HLS Group',
      output_group_settings: {
        type: 'HLS_GROUP_SETTINGS',
        hls_group_settings: {
          destination: "#{output_s3_url}/hls/",
          segment_length: 10,
          min_segment_length: 0,
          segment_control: 'SEGMENTED_FILES',
        }
      },
      outputs: [
        {
          container_settings: {
            container: 'M3U8',
            m3u8_settings: {}
          },
          video_description: {
            codec_settings: {
              codec: 'H_264',
              h264_settings: {
                rate_control_mode: 'CBR',
                scene_change_detect: 'ENABLED',
                quality_tuning_level: 'SINGLE_PASS',
                afd_signaling: 'NONE',
                fixed_afd: 'AFD_0000',
                color_metadata: 'INSERT'
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
    },
    {
      name: 'DASH ISO Group',
      output_group_settings: {
        type: 'DASH_ISO_GROUP_SETTINGS',
        dash_iso_group_settings: {
          destination: "#{output_s3_url}/dash/",
          segment_length: 10,
          min_segment_length: 0,
          segment_control: 'SEGMENTED_FILES'
        }
      },
      outputs: [
        {
          container_settings: {
            container: 'M4A',
            m4a_settings: {}
          },
          video_description: {
            codec_settings: {
              codec: 'H_264',
              h264_settings: {
                rate_control_mode: 'CBR',
                scene_change_detect: 'ENABLED',
                quality_tuning_level: 'SINGLE_PASS',
                afd_signaling: 'NONE',
                fixed_afd: 'AFD_0000',
                color_metadata: 'INSERT'
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
  ]
}
