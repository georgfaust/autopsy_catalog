defmodule AutopsyCatalog do
  @catalog_path "#{:code.priv_dir(:autopsy_catalog)}/catalog.etf"
  @external_resource @catalog_path

  def get do
    @catalog_path |> File.read!() |> :erlang.binary_to_term()
  end
end
