require 'chef/handler'
require 'chef/handler'
require 'chef/resource/directory'

require'csv'

class Chef
  class Handler
    class TimeReport < ::Chef::Handler

      attr_reader :config

      def initialize(config={})
        @config = config
        @config[:path] ||= '/var/chef/reports'
        @config[:format] ||= 'csv'
        @config[:log] ||= 'yes'
        @resources = nil
        @cookbooks = Hash.new(0)
        @recipes = Hash.new(0)
        @config
      end

      def sort_resources
        @resources ||= run_status.all_resources.sort_by{ |r| -r.elapsed_time}
        @resources.each do |r|
          @cookbooks[r.cookbook_name] += r.elapsed_time
          @recipes["#{r.cookbook_name}::#{r.recipe_name}"] += r.elapsed_time
        end
      end

      def report
        sort_resources
        build_report_dir
        log_report
        case @config[:format]
        when 'csv'
         write_report_csv
        else
          write_report
        end
      end

      def log_report
        Chef::Log.info "Elapsed time per resource"
        Chef::Log.info "------------  -------------"
        @resources.each do |resource|
          Chef::Log.info "%12f %s" % [ resource.elapsed_time, "#{resource.resource_name}(#{resource.name})" ]
        end
        Chef::Log.info "Elapsed time per cookbook"
        Chef::Log.info "------------  -------------"
        @cookbooks.each do |cookbook, time|
          Chef::Log.info "%12f %s" % [ time, cookbook ]
        end
        Chef::Log.info "Elapsed time per recipe"
        Chef::Log.info "------------  -------------"
        @recipes.each do |recipe, time|
          Chef::Log.info "%12f %s" % [ time, recipe ]
        end
      end

      def write_report_csv
        savetime = Time.now.strftime("%Y%m%d%H%M%S")
        CSV.open("#{@config[:path]}/chef-run-report-#{savetime}.csv", 'w', {:force_quotes => true}) do |csv|
          # Resources
          csv << ['Resources']
          csv << %w(Elapsed_time Resource_name Source_cookbook Source_recipe Source_line)
          @resources.each do|resource|
            csv << [ resource.elapsed_time.to_s, "#{resource.resource_name}(#{resource.name})", resource.cookbook_name, resource.recipe_name, resource.source_line ]
          end
          # Cookbooks
          csv << ['Cookbooks']
          csv << %w(Name Elapsed_time)
          @cookbooks.each do|cookbook, time|
            csv << [ time, cookbook]
          end
          # Recipes
          csv << ['Recipes']
          csv << %w(Name Elapsed_time)
          @recipes.each do|recipe, time|
            csv << [ time, recipe]
          end
        end
        Chef::Log.info "CSV report generated : #{@config[:path]}/chef-run-report-#{savetime}.csv"
      end

      def write_report
      end

      def build_report_dir
        unless File.exists?(config[:path])
          FileUtils.mkdir_p(config[:path])
          File.chmod(00700, config[:path])
        end
      end
    end
  end
end
