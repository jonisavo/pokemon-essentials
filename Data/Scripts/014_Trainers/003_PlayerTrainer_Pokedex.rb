class PlayerTrainer
  # @return [Pokedex] player's Pokédex
  attr_reader :pokedex

  # Represents the player's Pokédex.
  class Pokedex
    # @return [Hash{Symbol => Boolean}] seen Pokémon hash
    attr_reader :seen
    # @return [Hash{Symbol => Boolean}] owned Pokémon hash
    attr_reader :owned
    # @return [Hash{Symbol => Array}] seen forms hash (species => [[], []])
    attr_reader :seen_forms
    # @return [Hash{Symbol => Array}] last seen forms (species => [gender, form])
    attr_reader :last_seen_forms
    # @return [Hash{Symbol => Boolean}] owned shadow Pokémon hash
    attr_reader :owned_shadow
    # @return [Array<Integer>] an array of viable dexes
    # @see {#refresh_viable_dexes}
    attr_reader :viable_dexes

    # Creates an empty Pokédex.
    def initialize
      @unlocked_dexes = []
      @viable_dexes = []
      0.upto(pbLoadRegionalDexes.length) do |i|
        @unlocked_dexes[i] = (i == 0)
      end
      self.clear
    end

    # Sets the given species as seen in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as seen
    def set_seen(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @seen[species_id] = true
      self.refresh_viable_dexes
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is seen
    def seen?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @seen[species_id] == true
    end

    # Returns whether there are any seen Pokémon.
    # If a region is given, returns whether there are seen Pokémon
    # in that region.
    # @param region [Integer] region ID
    # @return [Boolean] whether there are any seen Pokémon
    def seen_any?(region: -1)
      validate region => Integer
      if region == -1
        GameData::Species.each { |s| return true if s.form == 0 && @seen[s.species] }
      else
        pbAllRegionalSpecies(region).each { |s| return true if s && @seen[s] }
      end
      return false
    end

    # Returns the amount of seen Pokémon.
    # If a region ID is given, returns the amount of seen Pokémon
    # in that region.
    # @param region [Integer] region ID
    def seen_count(region: -1)
      validate region => Integer

      return self.count_species(@seen, region)
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is owned
    def owned?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @owned[species_id] == true
    end

    # Sets the given species as owned in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as owned
    def set_owned(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned[species_id] = true
      self.refresh_viable_dexes
    end

    # Returns the amount of owned Pokémon.
    # If a region ID is given, returns the amount of owned Pokémon
    # in that region.
    # @param region [Integer] region ID
    def owned_count(region: -1)
      validate region => Integer

      return self.count_species(@owned, region)
    end

    # Returns the amount of seen forms for the given species.
    # @param species [Symbol, GameData::Species] Pokémon species
    # @return [Integer] amount of seen forms
    def seen_forms_count(species)
      species_id = GameData::Species.try_get(species)&.species
      return 0 if species_id.nil?
      ret = 0
      @seen_forms[species_id] ||= [[], []]
      array = @seen_forms[species_id]
      for i in 0...[array[0].length, array[1].length].max
        ret += 1 if array[0][i] || array[1][i]
      end
      return ret
    end

    # @param dex_id [Integer] dex ID
    # @return [Boolean] whether the given dex is unlocked
    def unlocked?(dex_id)
      validate dex_id => Integer
      return @unlocked_dexes[dex_id] == true
    end

    # Unlocks the given dex, -1 being the national dex.
    # @param dex_id [Integer] dex ID (-1 is the national dex)
    def unlock_dex(dex_id)
      validate dex_id => Integer
      if dex_id < 0 || dex_id > self.unlocked_dex_count - 1
        dex_id = self.unlocked_dex_count - 1
      end
      @unlocked_dexes[dex_id] = true
      self.refresh_viable_dexes
    end

    # Locks the given dex, -1 being the national dex.
    # @param dex_id [Integer] dex ID (-1 is the national dex)
    def lock_dex(dex_id)
      validate dex_id => Integer
      if dex_id < 0 || dex_id > self.unlocked_dex_count - 1
        dex_id = self.unlocked_dex_count - 1
      end
      @unlocked_dexes[dex_id] = false
      self.refresh_viable_dexes
    end

    # @return [Integer] amount of unlocked dexes
    def unlocked_dex_count
      return @unlocked_dexes.count { |value| value == true }
    end

    # Shorthand for +self.viable_dexes.length+.
    # @return [Integer] amount of viable dexes
    def viable_dex_count
      return @viable_dexes.length
    end

    # Decides which dex lists are able to be viewed (i.e. they are unlocked and have
    # at least 1 seen species in them), and saves all viable dex region numbers
    # into {#viable_dexes} (National dex comes after regional dexes).
    # If the dex list shown depends on the player's location, this just decides if
    # a species in the current region has been seen - doesn't look at other regions.
    # Used to decide whether to show the Pokédex in the pause menu.
    def refresh_viable_dexes
      @viable_dexes = []
      dex_count = self.unlocked_dex_count
      if Settings::USE_CURRENT_REGION_DEX
        region = pbGetCurrentRegion
        region = -1 if region >= dex_count - 1
        @viable_dexes[0] = region if self.seen_any?(region: region)
        return
      end
      if dex_count == 1 # National Dex only
        if self.unlocked?(0) && self.seen_any?
          @viable_dexes << 0
        end
      else
        # Regional dexes + National Dex
        for i in 0...dex_count
          region_to_check = (i == dex_count - 1) ? -1 : i
          if @unlocked_dexes[i] && self.seen_any?(region: region_to_check)
            @viable_dexes << i
          end
        end
      end
    end

    # Clears the Pokédex.
    def clear
      @seen            = {}
      @owned           = {}
      @seen_forms      = {}
      @last_seen_forms = {}
      @owned_shadow    = {}
      self.refresh_viable_dexes
    end

    private

    # @param hash [Hash]
    # @param region [Integer]
    # @return [Integer]
    def count_species(hash, region = -1)
      ret = 0

      if region == -1
        GameData::Species.each { |s| ret += 1 if s.form == 0 && hash[s.species] }
      else
        pbAllRegionalSpecies(region).each { |s| ret += 1 if s && hash[s] }
      end

      return ret
    end
  end
end
