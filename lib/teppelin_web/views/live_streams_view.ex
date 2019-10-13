defmodule TeppelinWeb.LiveStreamsView do
  use TeppelinWeb, :view

  def get_card_type(viewers) do
    cond do
       viewers > 10000 -> "notice-success"
       viewers > 5000 and viewers <= 10000 -> "notice-warning"
       viewers > 1000 and viewers <= 5000  -> "notice-info"
       true -> "notice"
    end
  end

end