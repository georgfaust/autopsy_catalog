defmodule AutopsyCatalogTest do
  use ExUnit.Case

  test "loader" do
    assert [%{application_program_id: _} | _] = AutopsyCatalog.get()
  end

  test "order_number to app_id" do
    AutopsyCatalog.get_ordnernumers_to_appid() |> dbg
  end

  @tag :wip
  test "can I store catalog as json?" do
    e = AutopsyCatalog.get()
    j = Jason.encode!(e, pretty: true)
    from_j = Jason.decode!(j, keys: :atoms)

    dbg(e == from_j)
  end

  # @tag :wip
  # test "patch" do
  #   # dbg(AutopsyCatalog.get(), limit: :infinity)

  #   r =
  #     for app <- AutopsyCatalog.get(), app.manufacturer_name == "Albrecht Jung" do
  #       IO.inspect(Enum.map(app.modes, fn m -> m.id end))
  #     end
  #     |> List.flatten()
  #     |> Enum.uniq
  #     |> Enum.sort

  #   for x <- r do
  #     IO.puts(x)
  #   end

  #   # patched =
  #   #   for app <- AutopsyCatalog.get() do
  #   #     case app.application_program_id do
  #   #       "M-0004_A-1152-22-AED9-O000A" ->
  #   #         dbg(app.modes)
  #   #         %{
  #   #           app
  #   #           | modes:
  #   #               app.modes ++
  #   #                 [
  #   #                   %{
  #   #                     block: "trigger",
  #   #                     id: "mode_trigger_scene",
  #   #                     parameters: [
  #   #                       %{
  #   #                         global: false,
  #   #                         type: "TypeRestriction",
  #   #                         value: 0,
  #   #                         context: [[], []],
  #   #                         text: "Funktion",
  #   #                         fids: ["P-13_R-13//", "P-345_R-2256//"],
  #   #                         type_id: "PT-Funktion.20.28Wippe.29"
  #   #                       },
  #   #                       %{
  #   #                         global: false,
  #   #                         type: "TypeText",
  #   #                         value: "SCENE",
  #   #                         context: [],
  #   #                         text: "Bezeichnung der Wippe 1",
  #   #                         fids: ["P-942_R-434//", "P-334_R-2253//"],
  #   #                         type_id: "PT-.5FAllg.5FText.5FKnotenbezeichnung"
  #   #                       }
  #   #                     ],
  #   #                     n_channels: 2,
  #   #                     objects: [
  #   #                       %{
  #   #                         global: false,
  #   #                         cc: "CC_Scene_Call",
  #   #                         fids: ["O-37_R-814//", "O-43_R-1094//"],
  #   #                         function_text: "Schalten",
  #   #                         numbers: %{0 => 37, 1 => 43}
  #   #                       }
  #   #                     ]
  #   #                   }
  #   #                 ]
  #   #         }

  #   #       "M-0004_A-1151-22-3144-O000A" ->
  #   #         %{
  #   #           app
  #   #           | modes:
  #   #               app.modes ++
  #   #                 [
  #   #                   %{
  #   #                     block: "trigger",
  #   #                     id: "mode_trigger_scene",
  #   #                     parameters: [
  #   #                       %{
  #   #                         global: false,
  #   #                         type: "TypeRestriction",
  #   #                         value: 0,
  #   #                         context: [[]],
  #   #                         text: "Funktion",
  #   #                         fids: ["P-13_R-13//"],
  #   #                         type_id: "PT-Funktion.20.28Wippe.29"
  #   #                       },
  #   #                       %{
  #   #                         global: false,
  #   #                         type: "TypeText",
  #   #                         value: "SCENE",
  #   #                         context: [],
  #   #                         text: "Bezeichnung der Wippe 1",
  #   #                         fids: ["P-942_R-434//"],
  #   #                         type_id: "PT-.5FAllg.5FText.5FKnotenbezeichnung"
  #   #                       },
  #   #                       %{
  #   #                         global: false,
  #   #                         type: "TypeRestriction",
  #   #                         value: 4,
  #   #                         context: [],
  #   #                         text: "Funktion der Status-LED 1",
  #   #                         fids: ["P-162_R-183//"],
  #   #                         type_id: "PT-.5F.5FStatus.2DLED.20.2D.20Anzeigefunktion.20WSchalten"
  #   #                       }
  #   #                     ],
  #   #                     n_channels: 1,
  #   #                     objects: [
  #   #                       %{
  #   #                         global: false,
  #   #                         cc: "CC_Scene_Call",
  #   #                         fids: ["O-37_R-814//"],
  #   #                         function_text: "Schalten",
  #   #                         numbers: %{0 => 37}
  #   #                       }
  #   #                     ]
  #   #                   }
  #   #                 ]
  #   #         }

  #   #       _ ->
  #   #         app
  #   #     end
  #   #   end

  #   # File.write!("priv/catalog_patched.etf", :erlang.term_to_binary(patched))
  # end
end
