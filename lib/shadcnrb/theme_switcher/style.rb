# frozen_string_literal: true

class Shadcnrb::ThemeSwitcher::Style
  def swatch_button
    "group flex flex-col items-center gap-1 rounded-md p-2 text-xs cursor-pointer hover:bg-accent " \
      "data-[selected=true]:bg-accent data-[selected=true]:ring-1 data-[selected=true]:ring-ring"
  end

  def mode_button
    "flex items-center justify-center gap-1.5 rounded-md px-2 py-1.5 text-xs cursor-pointer hover:bg-accent " \
      "data-[selected=true]:bg-accent data-[selected=true]:ring-1 data-[selected=true]:ring-ring"
  end
end
