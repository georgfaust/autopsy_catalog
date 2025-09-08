defmodule AutopsyCatalogTest do
  use ExUnit.Case

  test "loader" do
    assert [%{application_program_id: _} | _] = AutopsyCatalog.get()
  end

  test "order_number to app_id" do
    AutopsyCatalog.get_ordnernumers_to_appid() |> dbg
  end
end
