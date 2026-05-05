defmodule AutopsyCatalog.Loader do
  import Enum

  def load_raw(path) do
    path |> File.read!() |> :erlang.binary_to_term()
  end

  def load_for_cuete(catalog) do
    for app <- catalog, order_number <- app.order_numbers, into: %{} do
      modes =
        for mode <- app.modes, into: %{} do
          parameters =
            for p <- mode.parameters do
              %{p | fids: decode_fids(p.fids), context: decode_context(p.context)}
            end

          objects =
            for o <- mode.objects, into: %{} do
              {String.to_atom(o.cc), %{o | fids: decode_fids(o.fids)}}
            end

          {
            String.to_atom(mode.id),
            %{mode | parameters: parameters, objects: objects} |> Map.put(:mode, mode.id)
          }
        end

      {order_number, modes}
    end
  end

  def load_for_planner(catalog) do
    for app <- catalog,
        order_number <- app.order_numbers,
        into: %{} do
      # TODO! this all assumes, that modes are uniq.
      # e.g. trigger in trigger-splat and trigger not possible
      # --> this seems better and should be done this way, block-names coult be generic then I think
      # --> cadtool does not need to know about blocks, just modes!

      mode_to_block =
        app.modes
        |> map(&{&1.id, &1.block})
        |> group_by(fn {mode, _} -> mode end, fn {_, block} -> block end)
        |> Map.new(fn {mode, blocks} ->
          case uniq(blocks) do
            [block] -> {mode, block}
            _ -> raise("unexpected")
          end
        end)

      blocks_n_channels =
        app.modes
        |> group_by(& &1.block, & &1.n_channels)
        |> Map.new(fn {block, n_channels_of_modes} -> {block, max(n_channels_of_modes)} end)

      mode_devchannels_per_channel =
        for mode <- app.modes, into: %{} do
          block_n_channels = blocks_n_channels[mode.block]
          devchannels_per_channel = div(block_n_channels, mode.n_channels)
          {mode.id, devchannels_per_channel}
        end

      blocks =
        for {block, mode_ids} <- group_by(app.modes, & &1.block, & &1.id), into: %{} do
          {
            block,
            %{
              devchannels_per_channel: Map.take(mode_devchannels_per_channel, mode_ids),
              slot_bound: slot_bound?(app.application_program_id, block),
              n_channels: blocks_n_channels[block]
            }
          }
        end

      {
        order_number,
        app
        |> Map.take([
          :application_program_id,
          :application_name,
          :mount_type,
          :manufacturer_id,
          :manufacturer_name,
          :hardware_to_program_id,
          :mount_type,
          :product_series
        ])
        |> Map.merge(%{order_number: order_number, blocks: blocks, mode_blocks: mode_to_block})
      }
    end
  end

  # ---

  defp decode_fid(encoded_fid) do
    case String.split(encoded_fid, "|") do
      [ref_id, "", ""] ->
        %{ref_id: ref_id, instance: nil}

      [ref_id, module_ref, instance_number_string] ->
        instance_number = String.to_integer(instance_number_string)

        %{
          ref_id: ref_id,
          instance: %{ref: module_ref, number: instance_number}
        }
    end
  end

  defp decode_fids(fids) do
    fids
    |> map(&decode_fid(&1))
    |> with_index()
    |> Map.new(fn {fid, index} -> {index, fid} end)
  end

  defp decode_context(context_equals) do
    for {context, index} <- with_index(context_equals), into: %{} do
      {index, map(context, &%{&1 | fid: decode_fid(&1.fid)})}
    end
  end

  # TODO move to autopsy
  defp slot_bound?(app_id, block_name) do
    slot_bound_lookup = %{
      {"M-0004_A-D131-21-C9F7-O000A", "trigger"} => true,
      {"M-0004_A-D132-21-1794-O000A", "trigger"} => true,
      {"M-0004_A-D133-21-7C78-O000A", "trigger"} => true,
      {"M-0004_A-D134-21-67E4-O000A", "trigger"} => true,
      {"M-0004_A-D141-21-39B8-O000A", "trigger"} => true,
      {"M-0004_A-D142-21-8848-O000A", "trigger"} => true,
      {"M-0004_A-D143-21-AB5B-O000A", "trigger"} => true,
      {"M-0004_A-D144-21-4C84-O000A", "trigger"} => true,
      {"M-0004_A-1151-22-3144-O000A", "trigger"} => true,
      {"M-0004_A-1152-22-AED9-O000A", "trigger"} => true
    }

    Map.get(slot_bound_lookup, {app_id, block_name}, false)
  end
end

defmodule AutopsyCatalog do
  @catalog_path "#{:code.priv_dir(:autopsy_catalog)}/catalog.etf"
  @external_resource @catalog_path
  @catalog_raw AutopsyCatalog.Loader.load_raw(@catalog_path)
  @catalog_planner AutopsyCatalog.Loader.load_for_planner(@catalog_raw)
  @catalog_cuete AutopsyCatalog.Loader.load_for_cuete(@catalog_raw)

  def get, do: @catalog_raw
  def get_planner_catalog, do: @catalog_planner
  def get_cuete_catalog, do: @catalog_cuete

  def get_ordnernumers_to_appid() do
    for app <- @catalog_raw, order_number <- app.order_numbers, into: %{} do
      {order_number, app.application_program_id}
    end
  end
end
