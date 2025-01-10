defmodule ProjWeb.Layouts.App do
  alias Phoenix.LiveView.JS

  def toggle_dropdown_menu_down() do
    JS.toggle(
      to: "#dropdown_menu",
      in:
        {"transition ease-out duration-100", "transform opacity-0 translate-y-[-10%]",
         "transform opacity-100 translate-y-0"},
      out:
        {"transition ease-in duration-75", "transform opacity-100 translate-y-0",
         "transform opacity-0 translate-y-[-10%]"}
    )
  end

  # def toggle_sidebar_left() do
  #   JS.toggle(
  #     to: "#sidebar_container",
  #     in:
  #       {"transition ease-out duration-100", "transform translate-x-[100%]",
  #        "transform translate-x-0"},
  #     out:
  #       {"transition ease-in duration-75", "transform translate-x-0",
  #        "transform translate-x-[100%]"}
  #   )
  # end
end
