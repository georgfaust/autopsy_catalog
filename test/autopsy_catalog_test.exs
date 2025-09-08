defmodule AutopsyCatalogTest do
  use ExUnit.Case

  test "loader" do
    assert [%{application_program_id: _} | _] = AutopsyCatalog.get()
  end
end
