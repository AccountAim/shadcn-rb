# frozen_string_literal: true

module Shadcnrb
  module FormBuilder
    # FormBuilder subclass that injects shadcnrb component classes into every
    # field it renders.
    #
    #   form_with(model: @user, builder: Shadcnrb::FormBuilder::Component) do |f|
    #     f.label :email
    #     f.email_field :email
    #     f.submit
    #   end
    #
    # Or call `f.field :email, label: "Email", hint: "..."` for a bundled
    # label + control + hint/error stack using the `form_field` component.
    class Component < ActionView::Helpers::FormBuilder
      def text_field(method, options = {});     super(method, _inject(options, input_classes)); end
      def email_field(method, options = {});    super(method, _inject(options, input_classes)); end
      def password_field(method, options = {}); super(method, _inject(options, input_classes)); end
      def number_field(method, options = {});   super(method, _inject(options, input_classes)); end
      def telephone_field(method, options = {}); super(method, _inject(options, input_classes)); end
      alias_method :phone_field, :telephone_field
      def url_field(method, options = {});      super(method, _inject(options, input_classes)); end
      def search_field(method, options = {});   super(method, _inject(options, input_classes)); end
      def date_field(method, options = {});     super(method, _inject(options, input_classes)); end
      def datetime_field(method, options = {}); super(method, _inject(options, input_classes)); end
      def datetime_local_field(method, options = {});
 super(method, _inject(options, input_classes)); end
      def time_field(method, options = {});     super(method, _inject(options, input_classes)); end
      def month_field(method, options = {});    super(method, _inject(options, input_classes)); end
      def week_field(method, options = {});     super(method, _inject(options, input_classes)); end
      def color_field(method, options = {});    super(method, _inject(options, input_classes)); end
      def file_field(method, options = {});     super(method, _inject(options, input_classes)); end
      def range_field(method, options = {});    super(method, _inject(options, input_classes)); end

      def text_area(method, options = {})
        super(method, _inject(options, textarea_classes))
      end

      def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
        super(method, _inject(options, checkbox_classes), checked_value, unchecked_value)
      end

      def radio_button(method, tag_value, options = {})
        super(method, tag_value, _inject(options, radio_classes))
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        html_options = _inject(html_options, select_classes)
        # Rails emits the <select> directly. Wrap it in our chevron-bearing div.
        inner = super(method, choices, options, html_options, &block)
        @template.content_tag(:div, class: select_wrapper_classes, 
data: { slot: "native-select-wrapper" }) do
          inner + @template.sui.icon(:"chevron-down", class: select_chevron_classes)
        end
      end

      def label(method, text = nil, options = {}, &block)
        super(method, text, _inject(options, label_classes), &block)
      end

      def submit(value = nil, options = {})
        super(value, _inject(options, button_classes))
      end

      def button(value = nil, options = {}, &block)
        super(value, _inject(options, button_classes), &block)
      end

      # Bundled shortcut: renders `form_field` with label + control + hint/error
      # around the requested input type. Use when you want a quick stacked layout.
      #
      #   f.field :email, label: "Email", hint: "We never share this."
      #   f.field :bio,   label: "Bio",   as: :text_area
      def field(method, label: nil, hint: nil, as: :text_field, **opts)
        error_msg = _error_for(method)
        control = send(as, method, opts)
        @template.sui.form_field(label:, hint:, error: error_msg, 
for_id: field_id(method)) {
 control }
      end

      private

      def _inject(options, classes)
        merged = Shadcnrb::TailwindMerge.call(classes, options[:class])
        options.merge(class: merged)
      end

      def _error_for(method)
        return nil unless @object.respond_to?(:errors)
        @object.errors[method]&.first
      end

      def input_classes;    Shadcnrb::Input.style.base;    end
      def textarea_classes; Shadcnrb::Textarea.style.base; end
      def checkbox_classes; Shadcnrb::Checkbox.style.base; end
      def radio_classes;    Shadcnrb::RadioGroup.style.item; end
      def select_classes;   Shadcnrb::Select.style.base;   end
      def select_wrapper_classes; Shadcnrb::Select.style.wrapper; end
      def select_chevron_classes; Shadcnrb::Select.style.chevron; end
      def label_classes;    Shadcnrb::Label.style.base; end
      def button_classes
        style = Shadcnrb::Button.style
        "#{style.base} #{style.variants[:default]} #{style.sizes[:default]}"
      end
    end
  end
end
