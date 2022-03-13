module Extra
  def clear_screen
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def press_enter_to_continue
    puts
    puts style.view("Press enter to continue...", italic: true)
    $stdin.gets
    clear_screen
  end

  def loading(n_times = 5)
    n_times.times do
      sleep 0.5
      print "."
    end
  end

  DIFF_COL = {
    "random" => :gray,
    "easy" => :green,
    "medium" => :yellow,
    "hard" => :red
  }.freeze

  class Colorizator
    COLORS = { default: "38", black: "30", red: "31", green: "32", brown: "38", blue: "34", purple: "35",
               cyan: "36", gray: "37", dark_gray: "1;30", light_red: "1;31", light_green: "1;32", yellow: "1;33",
               light_blue: "1;34", light_purple: "1;35", light_cyan: "1;36", white: "1;37" }.freeze
    BG_COLORS = { default: "0", black: "40", red: "41", green: "42", brown: "43", blue: "44",
                  purple: "45", cyan: "46", gray: "47", dark_gray: "100", light_red: "101", light_green: "102",
                  yellow: "103", light_blue: "104", light_purple: "105", light_cyan: "106", white: "107" }.freeze
    FONT_OPTIONS = { bold: "1", dim: "2", italic: "3", underline: "4", reverse: "7", hidden: "8" }.freeze

    def self.view(text, color = :default, bg_color = :default, **options)
      color_code = COLORS[color]
      bg_color_code = BG_COLORS[bg_color]
      font_options = options.select { |k, v| v && FONT_OPTIONS.key?(k) }.keys
      font_options = font_options.map { |e| FONT_OPTIONS[e] }.join(";").squeeze
      "\e[#{bg_color_code};#{font_options};#{color_code}m#{text}\e[0m".squeeze(";")
    end
  end
end
