Puppet::Functions.create_function(:'graphite_clickhouse_rollup') do
    dispatch :generate_retentions_config do
      required_param 'Hash', :config
      return_type 'String'
    end

    def generate_retentions_config(config)
        xml = "<yandex>\n\t<graphite_rollup>\n\t\t<path_column_name>Path</path_column_name>\n\t\t<time_column_name>Time</time_column_name>\n\t\t<value_column_name>Value</value_column_name>\n\t\t<version_column_name>Timestamp</version_column_name>\n"
        config.each { |name, configuration|
            pattern_text = "pattern"
            if name == "default" 
                pattern_text = "default"
            end
            retentions = parse_retentions_def(configuration["retentions"])
            xml += "\t\t<!-- %s -->\n" % [name]
            xml += "\t\t<%s>\n" % [pattern_text]
            if name != "default"
                xml += "\t\t\t<regexp>%s</regexp>\n" % [configuration["pattern"]]
            end
            if configuration.has_key?("aggregationMethod")
                xml += "\t\t\t<function>%s</function>\n" % [configuration["aggregationMethod"]]
            end
            last_age = 0
            retentions.each { |retention|
                xml += "\t\t\t<retention>\n"
                xml += "\t\t\t\t<age>%d</age>\n" % [last_age]
                last_age = retention["numberOfPoints"] * retention["secondsPerPoint"]
                xml += "\t\t\t\t<precision>%d</precision>\n" % [retention["secondsPerPoint"]]
                xml += "\t\t\t</retention>\n"
            }
            xml += "\t\t</%s>\n" % [pattern_text]
        }
        xml += "\t</graphite_rollup>\n</yandex>"
        return xml
    end

    def parse_retentions_def(retentions)
        ret = []
        retentions.split(",").each { |retentionDef|
            retentionDef.delete(' ')
            parts = retentionDef.split(":")
            if parts.length != 2
                raise "Not enough parts in retention defenition"
            end
            precision = parse_retention_part(parts[0])
            points = parse_retention_part(parts[1])
            points = points / precision
            ret += [{
                "secondsPerPoint" => precision,
                "numberOfPoints" => points,
            }]
        }
        return ret
    end

    def parse_retention_part(retentionPart)
        if convert_to_i(retentionPart) != nil
            return Integer(retentionPart)
        end
        retentionRegexp = Regexp.compile("^(\\d+)([smhdwy]+)$")
        if !retentionRegexp.match(retentionPart)
            raise "Unable to parse retention"
        end
        matches = retentionRegexp.match(retentionPart)
        value = Integer(matches[1])
        multiplier = unit_multiplier(matches[2])
        return multiplier * value
    end

    def unit_multiplier(unit)
        case unit
        when "s"
             return 1
        when "m"
            return 60
        when "h"
            return 3600
        when "d"
            return 86400
        when "w"
            return 86400 * 7
        when "y"
           return 86400 * 365
        end
        return 0
    end

    def convert_to_i(str)
        begin
          Integer(str)
        rescue ArgumentError
          nil
        end
    end
end
