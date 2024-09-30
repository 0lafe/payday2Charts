class ImageAtlasGenerator
  
  def self.create_image_atlas
    stats = [
      "melee_kills",
      "melee_used",
      "weapon_kills",
      "weapon_used",
      "weapon_shots",
      "weapon_hits",
      "mask_used",
      "gloves_used",
      "suit_used",
      "armor_used",
      "grenade_kills",
      "grenade_used",
      "gadget_used",
      "difficulty",
      "character_used"
    ]

    p "getting images"
		stats.each do |stat|
			self.get_stat_names(stat).each do |individual_stat|
        atlas = Localizer.get_image_atlas(individual_stat)
        Dir.mkdir "tmp/image_out/#{atlas}" unless Dir.exist?("tmp/image_out/#{atlas}")
        uuid = Localizer.isolate_statistic_uuid(individual_stat)

        if atlas && !File.file?("tmp/image_out/#{atlas}/#{uuid}.png")
          image_url = Localizer.generate_image_url(individual_stat)
          File.open("tmp/image_out/#{atlas}/#{uuid}.png", 'wb') do |f|
            f.write(URI.open(image_url).read)
          end
        end
			end
		end

    self.format_files
  end

  def self.stitch_atlas
    p "stitching atlases"

    mappings = {
      atlases: {},
      images: {}
    }
    Dir.children("tmp/image_out").each do |atlas|
      image_count = Dir.children("tmp/image_out/#{atlas}").length
      first_file = Dir.children("tmp/image_out/#{atlas}").first
      first_image = Magick::Image.ping("tmp/image_out/#{atlas}/#{first_file}").first
      x_dim = first_image.columns
      y_dim = first_image.rows
      mappings[:atlases][atlas] = [x_dim, y_dim]

      root_diff = ( y_dim.to_f / x_dim ) ** 0.5
      base_root = image_count ** 0.5
      x_count = (base_root * root_diff).ceil
      y_count = (image_count.to_f / x_count).ceil
      base_image = Magick::Image.new(x_count * x_dim, y_count * y_dim) { |options| options.background_color = "none" }
      base_image.alpha(Magick::ActivateAlphaChannel)

      Dir.glob("tmp/image_out/#{atlas}/*").each_with_index do |full_path, index|
        image = Magick::Image.read(full_path).first
        image.alpha(Magick::ActivateAlphaChannel)
        x_pos = ( index % x_count ) * x_dim
        y_pos = ( index / x_count ).floor * y_dim
        base_image.composite!(image, x_pos, y_pos, Magick::ReplaceCompositeOp)

        uuid = full_path.split("/").last.gsub(".png", "")
        mappings[:images][uuid] = [x_pos, y_pos]
      end
      base_image.write("tmp/atlas/#{atlas}.png")
    end
    self.write_css(mappings)
  end

  def self.write_css(mappings)
    atlases = mappings[:atlases].map do |image_data|
      ".#{image_data[0]}_atlas {\n  background-size: #{image_data[1][0]}px #{image_data[1][1]}px;\n  background: url('#{image_data[0]}.png') 0 0 no-repeat;\n}"
    end
    atlases = atlases.join("\n")
    offsets = mappings[:images].map do |image_data|
      "##{image_data[0]}_offset {\n  background-position: #{image_data[1][0]}px #{image_data[1][1]}px;\n}"
    end
    offsets = offsets.join("\n")

    File.open("tmp/atlas/output.scss", "w") do |file|
      file.write(atlases + "\n" + offsets)
    end
  end
  # deletes non images and resizes weird ones
  def self.format_files
    p "formatting files"
    Dir.children("image_out").each do |atlas|
      first_file = Dir.children("image_out/#{atlas}").first
      first_image = Magick::Image.ping("image_out/#{atlas}/#{first_file}").first
      x_dim = first_image.columns
      y_dim = first_image.rows
      Dir.children("image_out/#{atlas}").each do |image_path|
        full_path = "image_out/#{atlas}/#{image_path}"
        begin
          image = Magick::Image.ping(full_path).first
          if image.columns != x_dim || image.rows != y_dim
            image = Magick::Image.read(full_path).first
            image.resize!(x_dim, y_dim)
            p "resizing #{full_path}"
            image.write(full_path)
          end
        rescue Magick::ImageMagickError
          p "deleting #{full_path}"
          File.delete(full_path)
        end
      end
    end

    self.stitch_atlas
  end

  def self.get_schema
    response = HTTParty.get("https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=#{ENV['STEAM_KEY']}&appid=218620")
    if response.ok?
      data = JSON.parse(response.body)
      return data
    else
      return {error: response.headers}
    end
  end

  def self.get_stat_names(stat_type)
    stats = self.get_schema['game']['availableGameStats']['stats']
    stats = stats.filter {|stat| stat['name'].index(stat_type) == 0 }.map {|stat| stat['name'] }
    stats = stats.filter {|stat| !self.black_list.include?(stat) }
  end

  def self.black_list
    [
      'weapon_kills_tec9',
      'grenade_kills_wpn_prj_ace',
      'suit_used_poolrepair_default',
      'weapon_shots_model70',
      'weapon_shots_x_p226',
      'weapon_shots_x_rage',
      'weapon_shots_x_uzi',
      'weapon_hits_x_akmsu',
      'weapon_hits_tecci',
      'weapon_hits_breech',
      'weapon_hits_tti',
      'weapon_hits_x_m45',
      'weapon_hits_coach',
      'player_time',
      'player_rank',
      'player_cash',
      'player_level',
      'player_coins',
      'skill_hoxton',
      'skill_chains',
      'skill_wolf',
      'skill_dallas',
      'skill_houston',
      'skill_mastermind',
      'skill_enforcer',
      'skill_ghost',
      'skill_technician',
      'skill_fugative'
    ]
  end
end