<div align="center">

##**LUMINOSITY 
HUB**

[![Version](https://img.shields.io/badge/version-2.0-red.svg)](https://github.com/Jshawk/luminosity-ui)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-Active-success.svg)](https://github.com/Jshawk/luminosity-ui)
[![Platform](https://img.shields.io/badge/platform-Roblox-blueviolet.svg)](https://www.roblox.com)

**A powerful, feature-rich universal Roblox script with advanced aimbot, ESP, and visual enhancements**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Compatibility](#-compatibility) • [Credits](#-credits)

</div>

---

## ✨ Features

**Luminosity** is a comprehensive universal Roblox script demonstration with advanced features:

- 🎯 **Advanced Aimbot** - Precision targeting with customizable settings
- 👁️ **ESP System** - Complete player awareness with multiple visual options
- 🎨 **Visual Enhancements** - Improve your game's visuals and visibility
- ⚡ **Movement Utilities** - Enhanced character movement and teleportation
- 🎮 **Fully Customizable** - Extensive configuration options for every feature
- 🆓 **Completely Free** - No paywalls or premium features
- 🌐 **Universal Support** - Works on most Roblox games
- 🔧 **Regular Updates** - Actively maintained and improved

---

## 📥 Installation

### Quick Install

> **⚠️ Security Note**: Always review code before executing it. The loadstring below fetches the script from this repository.

Simply execute the following loadstring in your preferred Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Jshawk/luminosity-ui/refs/heads/main/main.lua"))()
```

### Manual Installation

1. Download the `main.lua` file from this repository
2. Copy the entire script content
3. Paste it into your executor
4. Execute and enjoy!

---

## 🎮 Usage

1. **Launch Roblox** and join any supported game
2. **Open your executor** (Synapse, KRNL, Fluxus, etc.)
3. **Paste the loadstring** from the installation section
4. **Execute** the script
5. **Wait for the UI** to load (animated loading screen)
6. **Configure your settings** and explore the features!

### Keybinds

The script uses customizable keybinds that you can configure in the UI:
- Default keybinds can be set for each feature
- All keybinds are saved automatically
- Easy toggle system for quick feature activation

---

## 🔧 Detailed Features

<details>
<summary><b>🎯 Aimbot System</b> (Click to expand)</summary>

### Main Settings
- ✅ **Enable/Disable** - Master toggle for aimbot functionality
- 🔑 **Custom Keybind** - Set your preferred aimbot activation key
- 👥 **Team Check** - Avoid targeting teammates
- 🧱 **Wall Check** - Only target visible enemies
- 🎛️ **Smoothness** - Adjustable aim smoothing (0-100%)
- 📊 **Prediction** - Lead moving targets with velocity prediction
- 🎯 **Prediction Multiplier** - Fine-tune prediction accuracy

### Targeting Options
- 🎯 **Body Part Selection** - Choose target: Head, Torso, HumanoidRootPart, etc.
- 📍 **Priority Modes**:
  - Nearest to Cursor
  - Nearest to Character
  - Lowest Health
  - Highest Health
- 🔒 **Sticky Target** - Lock onto a target until they're eliminated
- 📏 **Max Distance** - Set maximum targeting range (0-5000 studs)

### FOV Circle
- 👁️ **Visible FOV Circle** - Visual indicator of targeting area
- 📐 **Adjustable Radius** - Customize FOV size (10-500)
- 🎨 **Custom Colors** - Choose your FOV circle color
- 🌈 **Rainbow Mode** - Animated rainbow FOV effect
- 💧 **Fill Transparency** - Optional filled circle with adjustable opacity
- 🖱️ **Third Person Mode** - FOV follows mouse cursor

### Silent Aim
- 🤫 **Silent Aim Toggle** - Hit targets without moving camera
- 🔑 **Separate Keybind** - Independent activation key
- 🎲 **Hit Chance** - Adjustable accuracy (0-100%)
- 📏 **FOV Radius** - Separate FOV for silent aim

</details>

<details>
<summary><b>👁️ ESP & Visuals</b> (Click to expand)</summary>

### Player ESP
- ✅ **Master ESP Toggle** - Enable/disable all ESP features
- 🔑 **ESP Keybind** - Quick toggle with custom key
- 👥 **Team Check** - Hide ESP for teammates
- 📦 **Box ESP** - Outline players with boxes
  - 2D Boxes
  - 3D Boxes (coming soon)
  - Customizable box styles
- 📝 **Name ESP** - Display player names
- ❤️ **Health ESP** - Visual health indicators
  - Bar display
  - Position options (Left, Right, Top, Bottom)
  - Color-coded by health percentage
- 📏 **Distance ESP** - Show distance to players
- 📍 **Tracers** - Lines pointing to players
  - Top, Middle, or Bottom origin points
  - Rainbow tracer option
- 💀 **Skeleton ESP** - Show player skeleton structure
- 🎭 **Chams** - Highlight players through walls
  - Adjustable transparency
  - Custom colors
- 🔫 **Weapon/Tool ESP** - Display equipped items
- 📏 **Max Distance** - Set ESP rendering distance

### ESP Customization
- 🎨 **Custom Colors** for all ESP elements:
  - Box color
  - Name color
  - Tracer color
  - Skeleton color
  - Chams color
- 🌈 **Rainbow Effects**:
  - Rainbow boxes
  - Rainbow tracers
  - Animated color cycling
- 📊 **Transparency Controls** - Adjust opacity for all elements

### Crosshair
- ➕ **Custom Crosshair** - Replace default crosshair
- 🎨 **Styles**: Cross, Circle, Square, Dot
- 📏 **Adjustable Size** - Customize crosshair dimensions
- 🎨 **Custom Color** - Choose your crosshair color
- 🌈 **Rainbow Mode** - Animated rainbow crosshair
- 💪 **Outline** - Add outline for better visibility
- 📊 **Outline Thickness** - Adjust outline size

### World Visuals
- ☀️ **Fullbright** - Maximum lighting in all areas
- 🌫️ **No Fog** - Remove distance fog
- 🌙 **Ambient Lighting** - Customize world brightness
- 🎥 **Camera FOV** - Adjust field of view (70-120)
  - Default: 70
  - Recommended: 90-100
  - Max: 120
- 🌈 **Rainbow Effects** - Global rainbow mode

</details>

<details>
<summary><b>⚡ Misc Features</b> (Click to expand)</summary>

### Movement
- 🏃 **WalkSpeed Modifier** - Adjust movement speed (1x-10x)
- 🦘 **JumpPower Modifier** - Increase jump height (1x-10x)
- ✈️ **Fly Mode** - Fly around the map freely
- 👻 **Noclip** - Walk through walls and objects
- 🎯 **SpinBot** - Automatic character rotation

### Utility
- 🎮 **Anti-AFK** - Prevent being kicked for inactivity
- 💾 **Position Saving** - Save and load positions
- 📍 **Player Teleportation** - Teleport to other players
- 🔄 **Quick Teleport Keybind** - Fast position loading
- 🎪 **Fun Effects** - Various entertainment features

### Server Management
- 🔄 **Server Hop** - Switch to a different server
- 🔁 **Rejoin Server** - Reconnect to current server
- 📊 **Server Info** - Display server statistics

</details>

---

## 💻 Compatibility

### ✅ Supported Executors

Luminosity is designed to work with **all major Roblox executors**, including but not limited to:

- ✔️ **Synapse X** / **Synapse Z**
- ✔️ **Script-Ware**
- ✔️ **KRNL**
- ✔️ **Fluxus**
- ✔️ **Oxygen U**
- ✔️ **Electron**
- ✔️ **Arceus X** (Mobile)
- ✔️ **Codex**
- ✔️ **JJSploit**
- ✔️ And most other executors!

### 🎮 Game Compatibility

- **Universal Script** - Works on the majority of Roblox games
- Tested and verified on popular games
- Continuously updated for compatibility
- Some game-specific features may vary

> **Note**: Performance and feature availability may vary depending on your executor and the specific Roblox game you're playing.

---

## 👨‍💻 Credits

<div align="center">

### 🌟 Developer

**[@jshawk](https://github.com/Jshawk)** - Original Developer & Maintainer

### 🔗 Links

🌐 **Website**: [luminosityhub.com](https://luminosityhub.com)  
💬 **Discord**: Contact @jshawk  
📦 **GitHub**: [Jshawk/luminosity-ui](https://github.com/Jshawk/luminosity-ui)

### 🙏 Special Thanks

- **Octohook UI Library** - Base UI framework
- **The Roblox Scripting Community** - Inspiration and support
- **All Contributors** - Bug reports and feature suggestions

</div>

---

## ⚠️ Disclaimer

> **IMPORTANT**: This script is provided for **educational purposes only**.
>
> - ⚠️ **Use at your own risk** - The developer is not responsible for any consequences of using this script
> - 🚫 **Account safety** - Using scripts may result in account moderation or bans
> - 📜 **Terms of Service** - Using exploits violates Roblox's Terms of Service
> - 🎓 **Educational purpose** - This project is meant to demonstrate scripting capabilities
> - 🤝 **Respect others** - Don't use this to ruin other players' experiences
> - 💡 **Learn responsibly** - Study the code to improve your own programming skills

**By using this script, you acknowledge that you understand and accept these risks.**

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

### 🌟 Star this repository if you find it useful!

**Made with ❤️ by [@jshawk](https://github.com/Jshawk)**

![Luminosity](https://img.shields.io/badge/Luminosity-Hub-red?style=for-the-badge)

</div>
