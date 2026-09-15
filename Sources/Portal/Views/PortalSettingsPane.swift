import DroppyKit
import SwiftUI

struct PortalSettingsPane: View {
    @ObservedObject var droplet: PortalDroplet

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.lg) {
            DropletSettingsCard {
                DropletToggleRow(
                    title: "Show all ports",
                    subtitle: "Lists every port your account is listening on. Off, it keeps to the dev servers Portal recognises.",
                    isOn: droplet.showsEveryPortBinding
                )
                DropletSettingsDivider()
                DropletSliderRow(
                    title: "Check for changes",
                    value: seconds(droplet.pollInterval),
                    binding: droplet.pollIntervalBinding,
                    range: PortalDroplet.pollIntervalRange,
                    step: 0.5
                )
            }

            DropletSettingsCard {
                DropletToggleRow(
                    title: "Announce new servers",
                    subtitle: "Shows the newly opened port in the notch.",
                    isOn: droplet.announcesArrivalsBinding
                )
                DropletSettingsDivider()
                DropletToggleRow(
                    title: "Announce servers that close",
                    subtitle: "Shows when a port closes, in the notch.",
                    isOn: droplet.announcesDeparturesBinding
                )
                DropletSettingsDivider()
                DropletSliderRow(
                    title: "Keep it in the notch",
                    value: hold,
                    binding: droplet.notchHoldSecondsBinding,
                    range: PortalDroplet.notchHoldRange,
                    step: 1
                )
                .disabled(!droplet.announcesArrivals && !droplet.announcesDepartures)
            }

            DropletSettingsCard {
                DropletToggleRow(
                    title: "Show a menu bar item",
                    subtitle: "Shows Portal in your Mac's menu bar.",
                    isOn: droplet.showsMenuBarItemBinding
                )
            }

            DropletSettingsCard {
                DropletControlRow(title: "Listening now") {
                    DropletValuePill(text: "\(droplet.servers.count)")
                }
                DropletSettingsDivider()
                DropletControlRow(title: "Wi-Fi address") {
                    DropletValuePill(text: droplet.localNetworkAddress ?? "Not on a network")
                }
            }
        }
    }

    private var hold: String {
        droplet.notchHoldSeconds == 0 ? "Off" : seconds(droplet.notchHoldSeconds)
    }

    private func seconds(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))s" : String(format: "%.1fs", value)
    }
}
