# frozen_string_literal: true

# shadcn divergence: collapsed upstream `Field` set (`FieldSet`, `FieldLegend`,
# `FieldGroup`, `Field`, `FieldControl`, `FieldError`) into a single
# `form_field` wrapper. Rails FormBuilder (and `Shadcnrb::FormBuilder#field`)
# already subsumes Control/Error plumbing — the extra JSX primitives don't
# translate. upstream: field.tsx.

module Shadcnrb
  class FormField < Component
    def form_field(label: nil, hint: nil, error: nil, for_id: nil, **opts, &block)
      style = self.class.style
      opts[:class] = Shadcnrb::TailwindMerge.call(style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "form-field")
      content_tag(:div, **opts) do
        parts = []
        parts << self.label(label, for_id:) if label
        parts << (block ? capture(&block) : "".html_safe)
        parts << content_tag(:p, hint, class: style.description,
          data: { slot: "form-field-description" }) if hint && error.blank?
        parts << content_tag(:p, error, class: style.error,
          data: { slot: "form-field-error" }) if error.present?
        safe_join(parts)
      end
    end
  end
end
