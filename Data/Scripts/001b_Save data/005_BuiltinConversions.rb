# Contains conversions defined in Essentials by default.

SaveData.register_conversion(:v19_define_versions) do
  essentials_version 19
  display_title 'Adding game version and Essentials version to save data'
  to_all do |save_data|
    unless save_data.has_key?(:essentials_version)
      save_data[:essentials_version] = Essentials::VERSION
    end
    unless save_data.has_key?(:game_version)
      save_data[:game_version] = Settings::GAME_VERSION
    end
  end
end

SaveData.register_conversion(:v19_convert_PokemonSystem) do
  essentials_version 19
  display_title 'Updating PokemonSystem class'
  to_all do |save_data|
    new_system = PokemonSystem.new
    new_system.textspeed = save_data[:pokemon_system].textspeed || new_system.textspeed
    new_system.battlescene = save_data[:pokemon_system].battlescene || new_system.battlescene
    new_system.battlestyle = save_data[:pokemon_system].battlestyle || new_system.battlestyle
    new_system.frame = save_data[:pokemon_system].frame || new_system.frame
    new_system.textskin = save_data[:pokemon_system].textskin || new_system.textskin
    new_system.font = save_data[:pokemon_system].font || new_system.font
    new_system.screensize = save_data[:pokemon_system].screensize || new_system.screensize
    new_system.language = save_data[:pokemon_system].language || new_system.language
    new_system.runstyle = save_data[:pokemon_system].runstyle || new_system.runstyle
    new_system.bgmvolume = save_data[:pokemon_system].bgmvolume || new_system.bgmvolume
    new_system.sevolume = save_data[:pokemon_system].sevolume || new_system.sevolume
    new_system.textinput = save_data[:pokemon_system].textinput || new_system.textinput
    save_data[:pokemon_system] = new_system
  end
end

SaveData.register_conversion(:v19_move_pokedex_flag) do
  essentials_version 19
  display_title 'Moving Pokédex flag'
  to_all do |save_data|
    pokedex_access = false
    save_data[:player].instance_eval do
      pokedex_access = @pokedex.dup
    end
    save_data[:global_metadata].pokedex_access = pokedex_access
  end
end

SaveData.register_conversion(:v19_convert_player) do
  essentials_version 19
  display_title 'Converting player trainer class'
  to_all do |save_data|
    next if save_data[:player].is_a?(PlayerTrainer)
    # Conversion of the party is handled in PokeBattle_Trainer.convert
    save_data[:player] = PokeBattle_Trainer.convert(save_data[:player])
  end
end

SaveData.register_conversion(:v19_move_pokedex_dex_data) do
  essentials_version 19
  display_title 'Moving unlocked dexes from global metadata to PlayerTrainer::Pokedex'
  to_all do |save_data|
    unlocked_dexes = nil
    save_data[:global_metadata].instance_eval do
      unlocked_dexes = @pokedexUnlocked.dup
    end
    save_data[:player].pokedex.instance_eval do
      unless unlocked_dexes.nil?
        @unlocked_dexes = unlocked_dexes
        self.refresh_viable_dexes
      end
    end
    save_data[:global_metadata].instance_eval do
      @pokedexUnlocked = nil
      @pokedexViable = nil
    end
  end
end

SaveData.register_conversion(:v19_convert_global_metadata) do
  essentials_version 19
  display_title 'Adding encounter version variable to global metadata'
  to_value :global_metadata do |global|
    global.bridge ||= 0
    global.encounter_version ||= 0
    if global.pcItemStorage
      global.pcItemStorage.items.each_with_index do |slot, i|
        item_data = GameData::Item.try_get(slot[0])
        if item_data
          slot[0] = item_data.id
        else
          global.pcItemStorage.items[i] = nil
        end
      end
      global.pcItemStorage.items.compact!
    end
    if global.mailbox
      global.mailbox.each_with_index do |mail, i|
        global.mailbox[i] = PokemonMail.convert(mail) if mail
      end
    end
    if global.partner
      global.partner[0] = GameData::TrainerType.get(global.partner[0]).id
      global.partner[3].each_with_index do |pkmn, i|
        global.partner[3][i] = PokeBattle_Pokemon.convert(pkmn) if pkmn
      end
    end
    if global.daycare
      global.daycare.each do |slot|
        slot[0] = PokeBattle_Pokemon.convert(slot[0]) if slot && slot[0]
      end
    end
    if global.roamPokemon
      global.roamPokemon.each_with_index do |p, i|
        global.roamPokemon[i] = PokeBattle_Pokemon.convert(p) if p
      end
    end
    if global.hallOfFame
      global.hallOfFame.each do |team|
        next if !team
        team.each_with_index do |p, i|
          team[i] = PokeBattle_Pokemon.convert(p) if p
        end
      end
    end
    if global.triads
      global.triads.items.each do |card|
        card[0] = GameData::Species.get(card[0]).id if card && card[0] && card[0] != 0
      end
    end
  end
end

SaveData.register_conversion(:v19_convert_bag) do
  essentials_version 19
  display_title 'Converting item IDs in Bag'
  to_value :bag do |bag|
    bag.instance_eval do
      for pocket in self.pockets
        pocket.each_with_index do |item, i|
          next if !item || !item[0] || item[0] == 0
          item_data = GameData::Item.try_get(item[0])
          if item_data
            item[0] = item_data.id
          else
            pocket[i] = nil
          end
        end
        pocket.compact!
      end
      self.registeredIndex
      self.registeredItems.each_with_index do |item, i|
        next if !item
        if item == 0
          self.registeredItems[i] = nil
        else
          item_data = GameData::Item.try_get(item)
          if item_data
            self.registeredItems = item_data.id
          else
            self.registeredItems[i] = nil
          end
        end
      end
      self.registeredItems.compact!
    end # bag.instance_eval
  end # to_value
end

SaveData.register_conversion(:v19_convert_storage) do
  essentials_version 19
  display_title 'Converting classes of Pokémon in storage'
  to_value :storage_system do |storage|
    storage.instance_eval do
      for box in 0...self.maxBoxes
        for i in 0...self.maxPokemon(box)
          next unless self[box, i]
          self[box, i] = PokeBattle_Pokemon.convert(self[box, i])
        end
      end
    end # storage.instance_eval
  end # to_value
end
