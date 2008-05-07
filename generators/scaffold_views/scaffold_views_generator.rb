class ScaffoldViewsGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :resource_edit_path,
                :default_file_extension
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    if Rails::VERSION::STRING < "2.0.0"
      @resource_generator = "scaffold_resource"
      @default_file_extension = "rhtml"
                else
      @resource_generator = "scaffold"
      @default_file_extension = "html.erb"
    end

    if ActionController::Base.respond_to?(:resource_action_separator)
      @resource_edit_path = "/edit"
    else
      @resource_edit_path = ";edit"
    end
  end

  def manifest
    record do |m|

      # Controller, helper, views, and spec directories.
      m.directory(File.join('app/views', controller_class_path, controller_file_name))

      for action in scaffold_views
        m.template(
          "#{@resource_generator}:view_#{action}.#{@default_file_extension}",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.#{default_file_extension}")
        )
      end
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} controller_view ModelName [field:type field:type]"
    end

    def scaffold_views
      %w[ index show new edit ]
    end

    def model_name
      class_name.demodulize
    end
end

module Rails
  module Generator
    class GeneratedAttribute
      def default_value
        @default_value ||= case type
          when :int, :integer               then "\"1\""
          when :float                       then "\"1.5\""
          when :decimal                     then "\"9.99\""
          when :datetime, :timestamp, :time then "Time.now"
          when :date                        then "Date.today"
          when :string                      then "\"MyString\""
          when :text                        then "\"MyText\""
          when :boolean                     then "false"
          else
            ""
        end
      end

      def input_type
        @input_type ||= case type
          when :text                        then "textarea"
          else
            "input"
        end
      end
    end
  end
end
