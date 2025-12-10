#!/usr/bin/env bash
# Features: ROT13, ROT-n, Caesar brute, Atbash, Vigenere, base64, hex, URL, ASCII
# Session-only history (no files). Small deps: tr, awk, sed, base64, xxd/hexdump
# Author: ch3sda — 2025
# Edcucation only
# -----------------------

RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
NEON_PINK="\e[95m"
NEON_CYAN="\e[96m"
NEON_GREEN="\e[92m"
NEON_YELLOW="\e[93m"
NEON_BLUE="\e[94m"
HEART="❤"

credit(){
  clear
  echo -e "${NEON_PINK}${BOLD}"
  echo "╔═════════════════════════════════╗"
  echo "║            CryptME ${HEART}            ║"
  echo "║           by ch3sda             ║"
  echo "╚═════════════════════════════════╝"
  echo -e "${RESET}"
  sleep 1.5
}

warning_notice(){
  clear
  echo -e "${NEON_PINK}${BOLD}⚠ WARNING — READ CAREFULLY ⚠${RESET}"
  echo -e "${NEON_CYAN}"
  echo "This tool encrypts/decrypts text only."
  echo "Do NOT use for illegal hacking activities."
  echo ""
  echo "Allowed usage:"
  echo "  ✓ Learning"
  echo "  ✓ Cybersecurity study"
  echo "  ✓ CTF"
  echo "  ✓ Your OWN material"
  echo ""
  echo "NOT allowed:"
  echo "  ✗ Cracking private messages"
  echo "  ✗ Unauthorized surveillance"
  echo ""
  echo "You take full responsibility."
  echo ""
  read -p "Press ENTER if you agree..."
}

# RUN safety screens first
credit
warning_notice

# small helper for printing cute separators
sep(){ echo -e "${NEON_CYAN}────────────────────────────────────────────────${RESET}"; }

# session history (array)
HISTORY=()

push_hist(){ HISTORY+=("$1"); }

# check for optional commands
has_cmd(){ command -v "$1" >/dev/null 2>&1; }

# banner (figlet optional)
banner(){
  clear
  if has_cmd figlet; then
    echo -e "${NEON_PINK}"
    figlet -f small "CryptME"
    echo -e "${RESET}"
  else
    echo -e "${NEON_PINK}${BOLD}<<< CryptME ${HEART} >>>${RESET}"
  fi
  echo -e "${NEON_CYAN}CryptME ✦ friendly CLI — Bash shell${RESET}"
  echo -e "${NEON_CYAN}Check out https://github.com/ch3sda for more tools${RESET}"
  sep
}

# read input safely (preserve spaces)
read_input(){
  local prompt="$1"
  local var
  read -r -p "$prompt" var
  echo "$var"
}

# -----------------------
# Basic transformations
# -----------------------

# ROT13 (and general ROTn) - handles A-Za-z
rot_n(){
  local shift=$1
  local text="$2"
  # Build alphabets
  local ALPHA_UP="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local ALPHA_LOW="abcdefghijklmnopqrstuvwxyz"
  # create shifted versions
  local shifted_up="${ALPHA_UP:$shift}${ALPHA_UP:0:$shift}"
  local shifted_low="${ALPHA_LOW:$shift}${ALPHA_LOW:0:$shift}"
  echo "$text" | tr "${ALPHA_UP}${ALPHA_LOW}" "${shifted_up}${shifted_low}"
}

rot13(){
  echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# Atbash cipher (A<->Z, a<->z)
atbash(){
  local text="$1"
  echo "$text" | tr 'A-Za-z' 'Z-Az-a'
}

# Caesar brute force (tries all 25 shifts, shows readable candidate)
caesar_bruteforce(){
  local text="$1"
  for s in $(seq 1 25); do
    local forward=$((26 - s))
    local candidate
    candidate=$(rot_n $forward "$text")
    printf "Shift %2d -> %s\n" "$s" "$candidate"
  done
}

# -----------------------
# Vigenere (simple implementation)
# -----------------------
vigenere_process(){
  local mode="$1"; local key="$2"; local text="$3"
  key=$(echo "$key" | tr -cd 'A-Za-z' | tr 'a-z' 'A-Z')
  if [ -z "$key" ]; then
    echo "Key must contain letters."
    return 1
  fi
  awk -v mode="$mode" -v key="$key" '
  function mod(a,b){ return (a % b + b) % b }
  BEGIN{ kl=length(key); ki=1 }
  {
    for(i=1;i<=length($0);i++){
      c=substr($0,i,1)
      if (c ~ /[A-Za-z]/) {
        k = substr(key, ki, 1)
        if (k == "") { ki=1; k=substr(key,1,1) }
        shift = index("ABCDEFGHIJKLMNOPQRSTUVWXYZ", k) - 1
        if (mode == "dec") shift = -shift
        if (c ~ /[A-Z]/) { base = 65; val = ord(c) - base; n = mod(val + shift, 26); printf "%c", base + n }
        else { base = 97; val = ord(c) - base; n = mod(val + shift, 26); printf "%c", base + n }
        ki++; if (ki > kl) ki=1
      } else { printf "%s", c }
    }
    printf "\n"
  }
  function ord(str, r){ r = index("\0\1\2\3\4\5\6\7\10\11\12\13\14\15\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", str) - 1; if(r<0) r=sprintf("%d", str); return r }' <<< "$text"
}

vigenere_encode(){ vigenere_process "enc" "$1" "$2"; }
vigenere_decode(){ vigenere_process "dec" "$1" "$2"; }

# -----------------------
# Base64
# -----------------------
base64_enc(){ echo -n "$1" | base64; }
base64_dec(){ echo -n "$1" | base64 --decode 2>/dev/null || echo "Invalid base64"; }

# -----------------------
# Hex
# -----------------------
text_to_hex(){ echo -n "$1" | xxd -p | tr -d '\n'; echo; }
hex_to_text(){ echo -n "$1" | xxd -r -p 2>/dev/null || echo "Invalid hex"; echo; }

# -----------------------
# URL encode/decode
# -----------------------
url_encode(){
  local s="$1"; local out="" c o
  for ((i=0;i<${#s};i++)); do
    c="${s:i:1}"
    case "$c" in [a-zA-Z0-9.~_-]) out+="$c" ;; ' ') out+='+' ;; *) printf -v o '%%%02X' "'$c"; out+="$o" ;; esac
  done
  echo "$out"
}
url_decode(){ printf '%b\n' "${1//%/\\x}" | sed 's/+/ /g'; }

# -----------------------
# ASCII helpers
# -----------------------
text_to_ascii_codes(){ for ((i=0;i<${#1};i++)); do printf "%d " "'${1:i:1}"; done; echo; }
ascii_codes_to_text(){ for n in $1; do printf "\\$(printf '%03o' "$n")"; done; echo; }

# -----------------------
# UI actions
# -----------------------
pause(){ echo; read -r -p "Press Enter to continue…" ; }

show_history(){
  if [ ${#HISTORY[@]} -eq 0 ]; then
    echo -e "${NEON_YELLOW}No session history yet.${RESET}"
  else
    echo -e "${NEON_GREEN}Session history:${RESET}"
    for i in "${!HISTORY[@]}"; do printf "%2d) %s\n" $((i+1)) "${HISTORY[$i]}"; done
  fi
}

do_rot13(){ txt=$(read_input "Enter text (ROT13): "); out=$(rot13 "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "ROT13: $txt → $out"; }
do_rotn(){ txt=$(read_input "Enter text: "); s=$(read_input "Enter shift (1-25): "); [[ "$s" =~ ^[0-9]+$ ]] && [ "$s" -ge 1 ] && [ "$s" -le 25 ] || { echo -e "${NEON_YELLOW}Invalid shift.${RESET}"; return; }; out=$(rot_n "$s" "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "ROT$s: $txt → $out"; }
do_caesar_brute(){ txt=$(read_input "Enter ciphertext to bruteforce: "); echo; caesar_bruteforce "$txt"; push_hist "Caesar brute: $txt"; }
do_atbash(){ txt=$(read_input "Enter text (Atbash): "); out=$(atbash "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Atbash: $txt → $out"; }
do_vigenere(){ mode=$(read_input "Encode (e) or Decode (d)? [e/d]: "); if [[ "$mode" =~ ^[Ee]$ ]]; then key=$(read_input "Enter key (letters only): "); txt=$(read_input "Enter plaintext: "); out=$(vigenere_encode "$key" "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Vigenere-enc key=$key: $txt → $out"; elif [[ "$mode" =~ ^[Dd]$ ]]; then key=$(read_input "Enter key (letters only): "); txt=$(read_input "Enter ciphertext: "); out=$(vigenere_decode "$key" "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Vigenere-dec key=$key: $txt → $out"; else echo "Cancelled."; fi }
do_base64(){ mode=$(read_input "Encode (e) or Decode (d)? [e/d]: "); if [[ "$mode" =~ ^[Ee]$ ]]; then txt=$(read_input "Enter text to base64-encode: "); out=$(base64_enc "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Base64-enc: $txt → $out"; else txt=$(read_input "Enter base64 to decode: "); out=$(base64_dec "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Base64-dec: $txt → $out"; fi }
do_hex(){ mode=$(read_input "Text→Hex (t) or Hex→Text (h)? [t/h]: "); if [[ "$mode" =~ ^[Tt]$ ]]; then txt=$(read_input "Enter text: "); out=$(text_to_hex "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Text->Hex: $txt → $out"; else hex=$(read_input "Enter hex (no 0x, just digits): "); out=$(hex_to_text "$hex"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Hex->Text: $hex → $out"; fi }
do_url(){ mode=$(read_input "Encode (e) or Decode (d)? [e/d]: "); if [[ "$mode" =~ ^[Ee]$ ]]; then txt=$(read_input "Enter text to URL-encode: "); out=$(url_encode "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "URL-enc: $txt → $out"; else txt=$(read_input "Enter percent-encoded string: "); out=$(url_decode "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "URL-dec: $txt → $out"; fi }
do_ascii(){ mode=$(read_input "Text->Codes (t) or Codes->Text (c)? [t/c]: "); if [[ "$mode" =~ ^[Tt]$ ]]; then txt=$(read_input "Enter text: "); out=$(text_to_ascii_codes "$txt"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "Text->ASCII: $txt → $out"; else codes=$(read_input "Enter numbers separated by spaces: "); out=$(ascii_codes_to_text "$codes"); echo -e "${NEON_PINK}→ ${BOLD}$out${RESET}"; push_hist "ASCII->Text: $codes → $out"; fi }

# -----------------------
# Main menu loop
# -----------------------
while true; do
  banner
  echo -e "${NEON_GREEN}${BOLD}Menu${RESET}"
  echo -e "${NEON_CYAN}1)${RESET} ROT (ROT13 / ROT-n / BruteForce)"
  echo -e "${NEON_CYAN}2)${RESET} Atbash cipher"
  echo -e "${NEON_CYAN}3)${RESET} Vigenère (encode / decode)"
  echo -e "${NEON_CYAN}4)${RESET} Base64 (encode / decode)"
  echo -e "${NEON_CYAN}5)${RESET} Hex (text ↔ hex)"
  echo -e "${NEON_CYAN}6)${RESET} URL encode / decode"
  echo -e "${NEON_CYAN}7)${RESET} ASCII codes ↔ text"
  echo -e "${NEON_CYAN}h)${RESET} Show session history"
  echo -e "${NEON_CYAN}q)${RESET} Quit"
  sep
  choice=$(read_input "Choose an option: ")

  case "$choice" in
    1)
      rot_choice=$(read_input "Choose ROT type: 1) ROT13 2) ROT-n 3) Brute-force [1/2/3]: ")
      case "$rot_choice" in
        1) do_rot13 ;;
        2) do_rotn ;;
        3) do_caesar_brute ;;
        *) echo -e "${NEON_YELLOW}Invalid choice.${RESET}" ;;
      esac
      pause
      ;;
    2) do_atbash; pause ;;
    3) do_vigenere; pause ;;
    4) do_base64; pause ;;
    5) do_hex; pause ;;
    6) do_url; pause ;;
    7) do_ascii; pause ;;
    h|H) show_history; pause ;;
    q|Q) echo -e "${NEON_BLUE}Bye! ${HEART} Stay neon and cute.${RESET}"; exit 0 ;;
    *) echo -e "${NEON_YELLOW}Invalid choice.${RESET}"; pause ;;
  esac
done
