#!/usr/bin/env bash

rom_dir=$(echo "$1" | sed -e 's/\/$//')
sys_type="$(basename "$rom_dir")"

case "$sys_type" in
  'nes')
    rom_ext="nes"
    core_path="/tmp/cores/fceumm_libretro.so"
    core_name="Nintendo - NES / Famicom (FCEUmm)"
    db_name="Nintendo - Nintendo Entertainment System.lpl"
    ;;
  'atari2600')
    rom_ext="a26"
    core_path="/tmp/cores/stella_libretro.so"
    core_name="Atari - 2600 (Stella)"
    db_name="Atari - 2600.lpl"
    ;;
  'atarilynx')
    rom_ext="lnx"
    core_path="/tmp/cores/handy_libretro.so"
    core_name="Atari - Lynx (Handy)"
    db_name="Atari - Lynx.lpl"
    ;;
  'arcade')
    rom_ext="zip"
    core_path="/tmp/cores/mame2003_plus_libretro.so"
    core_name="Arcade (MAME 2003-Plus)"
    db_name="MAME 2003-Plus.lpl"
    ;;
  'pcengine')
    rom_ext="pce"
    core_path="/tmp/cores/mednafen_supergrafx_libretro.so"
    core_name="NEC - PC Engine SuperGrafx (Beetle SuperGrafx)"
    db_name="NEC - PC Engine - TurboGrafx 16.lpl"
    ;;
  'gba')
    rom_ext="gba"
    core_path="/tmp/cores/mgba_libretro.so"
    core_name="Nintendo - Game Boy Advance (mGBA)"
    db_name="Nintendo - Game Boy Advance.lpl"
    ;;
  'gbc')
    rom_ext="gbc"
    core_path="/tmp/cores/gambatte_libretro.so"
    core_name="Nintendo - Game Boy / Color (Gambatte)"
    db_name="Nintendo - Game Boy Color.lpl"
    ;;
  'gb')
    rom_ext="gb"
    core_path="/tmp/cores/gambatte_libretro.so"
    core_name="Nintendo - Game Boy / Color (Gambatte)"
    db_name="Nintendo - Game Boy.lpl"
    ;;
  'n64')
    rom_ext="z64"
    core_path="/tmp/cores/mupen64plus_next_libretro.so"
    core_name="Nintendo - Nintendo 64 (Mupen64Plus-Next)"
    db_name="Nintendo - Nintendo 64.lpl"
    ;;
  'snes')
    rom_ext="sfc"
    core_path="/tmp/cores/snes9x_libretro.so"
    core_name="Nintendo - SNES / SFC (Snes9x - Current)"
    db_name="Nintendo - Super Nintendo Entertainment System.lpl"
    ;;
  'ngpc')
    rom_ext="ngc"
    core_path="/tmp/cores/mednafen_ngp_libretro.so"
    core_name="SNK - Neo Geo Pocket / Color (Beetle NeoPop)"
    db_name="SNK - Neo Geo Pocket Color.lpl"
    ;;
  'gamegear')
    rom_ext="gg"
    core_path="/tmp/cores/genesis_plus_gx_libretro.so"
    core_name="Sega - MS/GG/MD/CD (Genesis Plus GX)"
    db_name="Sega - Game Gear.lpl"
    ;;
  'mastersystem')
    rom_ext="sms"
    core_path="/tmp/cores/genesis_plus_gx_libretro.so"
    core_name="Sega - MS/GG/MD/CD (Genesis Plus GX)"
    db_name="Sega - Master System - Mark III.lpl"
    ;;
  'megadrive')
    rom_ext="md"
    core_path="/tmp/cores/genesis_plus_gx_libretro.so"
    core_name="Sega - MS/GG/MD/CD (Genesis Plus GX)"
    db_name="Sega - Mega Drive - Genesis.lpl"
    ;;
  *)
    echo "Don't recognize system for roms in $sys_type directory..."
    exit 1
    ;;
esac

cat > temp.json <<EOF
{
  "version": "1.5",
  "default_core_path": "$core_path",
  "default_core_name": "$core_name",
  "base_content_directory": ".com/assets/cores/.index-dirs",
  "label_display_mode": 0,
  "right_thumbnail_mode": 0,
  "left_thumbnail_mode": 0,
  "sort_mode": 0,
  "items": [
EOF

echo "Reading roms from $rom_dir/*.$rom_ext..."
comma=
for rom in "$rom_dir"/*."$rom_ext"; do
  rom_file="$(basename "$rom" | sed 's/"/\\"/g')"
  if [ "$sys_type" = "arcade" ]; then
    mame_name="${rom_file%.$rom_ext}"
    rom_label="$(jq -r '.[] | select(.name=="'"$mame_name"'") | .description' mame2003plusdb.json | sed 's/\( ([^)]\+)\)*$//')"
  else
    rom_label="$(echo "$rom_file" | sed -e 's/\( ([^)]\+)\)*\.[^.]\+$//')"
  fi
  rom_path="/storage/roms/$sys_type/$rom_file"
  cat >> temp.json <<EOF
    $comma{
      "path": "$rom_path",
      "label": "$rom_label",
      "core_path": "$core_path",
      "core_name": "$core_name",
      "crc32": "DETECT",
      "db_name": "$db_name"
    }
EOF
  comma=','
done

cat >> temp.json <<EOF
  ]
}
EOF

if jq . temp.json > "$db_name"; then
  rm temp.json
fi
