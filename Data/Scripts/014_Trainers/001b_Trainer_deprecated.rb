#===============================================================================
# Deprecated
#===============================================================================
class PlayerTrainer
  # @deprecated Use {Pokedex#clear} instead. This alias is slated to be removed in v20.
  def clearPokedex
    Deprecation.warn_method('PlayerTrainer#clearPokedex', 'v20', 'Pokedex#clear')
    @pokedex.clear
  end

  # @deprecated Use {Pokedex#seen} instead. This alias is slated to be removed in v20.
  def seen
    Deprecation.warn_method('PlayerTrainer#sen', 'v20', 'Pokedex#seen')
    return @pokedex.seen
  end

  # @deprecated Use {Pokedex#owned} instead. This alias is slated to be removed in v20.
  def owned
    Deprecation.warn_method('PlayerTrainer#owned', 'v20', 'Pokedex#owned')
    return @pokedex.owned
  end

  # @deprecated Use {Pokedex#seen_forms} instead. This alias is slated to be removed in v20.
  def formseen
    Deprecation.warn_method('PlayerTrainer#formseen', 'v20', 'Pokedex#seen_forms')
    return @pokedex.seen_forms
  end

  # @deprecated Use {Pokedex#last_seen_forms} instead. This alias is slated to be removed in v20.
  def formlastseen
    Deprecation.warn_method('PlayerTrainer#formlastseen', 'v20', 'Pokedex#last_seen_forms')
    return @pokedex.last_seen_forms
  end

  # @deprecated Use {Pokedex#owned_shadow} instead. This alias is slated to be removed in v20.
  def shadowcaught
    Deprecation.warn_method('PlayerTrainer#shadowcaught', 'v20', 'Pokedex#owned_shadow')
    return @pokedex.owned_shadow
  end

  # @deprecated Use {Pokedex#set_seen} instead. This alias is slated to be removed in v20.
  def setSeen(species)
    Deprecation.warn_method('PlayerTrainer#setSeen', 'v20', 'Pokedex#set_seen')
    @pokedex.set_seen(species)
  end

  # @deprecated Use {Pokedex#set_owned} instead. This alias is slated to be removed in v20.
  def setOwned(species)
    Deprecation.warn_method('PlayerTrainer#setOwned', 'v20', 'Pokedex#set_owned')
    @pokedex.set_owned(species)
  end

  # @deprecated Use {Pokedex#seen_count} instead. This alias is slated to be removed in v20.
  def pokedexSeen(region = -1)
    Deprecation.warn_method('PlayerTrainer#pokedexSeen', 'v20', 'Pokedex#seen_count')
    @pokedex.seen_count(region: region)
  end

  # @deprecated Use {Pokedex#owned_count} instead. This alias is slated to be removed in v20.
  def pokedexOwned(region = -1)
    Deprecation.warn_method('PlayerTrainer#pokedexOwned', 'v20', 'Pokedex#owned_count')
    @pokedex.owned_count(region: region)
  end

  # @deprecated Use {Pokedex#seen_forms_count} instead. This alias is slated to be removed in v20.
  def numFormsSeen(species)
    Deprecation.warn_method('PlayerTrainer#numFormsSeen', 'v20', 'Pokedex#seen_forms_count')
    return @pokedex.seen_forms_count(species)
  end

  deprecated_method_alias :fullname, :full_name, removal_in: 'v20'
  deprecated_method_alias :publicID, :public_ID, removal_in: 'v20'
  deprecated_method_alias :secretID, :secret_ID, removal_in: 'v20'
  deprecated_method_alias :getForeignID, :make_foreign_ID, removal_in: 'v20'
  deprecated_method_alias :trainerTypeName, :trainer_type_name, removal_in: 'v20'
  deprecated_method_alias :moneyEarned, :base_money, removal_in: 'v20'
  deprecated_method_alias :skill, :skill_level, removal_in: 'v20'
  deprecated_method_alias :skillCode, :skill_code, removal_in: 'v20'
  deprecated_method_alias :hasSkillCode, :has_skill_code?, removal_in: 'v20'
  deprecated_method_alias :pokemonParty, :pokemon_party, removal_in: 'v20'
  deprecated_method_alias :ablePokemonParty, :able_party, removal_in: 'v20'
  deprecated_method_alias :partyCount, :party_count, removal_in: 'v20'
  deprecated_method_alias :pokemonCount, :pokemon_count, removal_in: 'v20'
  deprecated_method_alias :ablePokemonCount, :able_pokemon_count, removal_in: 'v20'
  deprecated_method_alias :firstParty, :first_party, removal_in: 'v20'
  deprecated_method_alias :firstPokemon, :first_pokemon, removal_in: 'v20'
  deprecated_method_alias :firstAblePokemon, :first_able_pokemon, removal_in: 'v20'
  deprecated_method_alias :lastParty, :last_party, removal_in: 'v20'
  deprecated_method_alias :lastPokemon, :last_pokemon, removal_in: 'v20'
  deprecated_method_alias :lastAblePokemon, :last_able_pokemon, removal_in: 'v20'
  deprecated_method_alias :hasSeen?, :seen?, removal_in: 'v20'
  deprecated_method_alias :hasOwned?, :owned?, removal_in: 'v20'
  deprecated_method_alias :numbadges, :badge_count, removal_in: 'v20'
  deprecated_method_alias :metaID, :character_ID, removal_in: 'v20'
  deprecated_method_alias :mysterygiftaccess, :mystery_gift_unlocked, removal_in: 'v20'
  deprecated_method_alias :mysterygift, :mystery_gifts, removal_in: 'v20'
end

class PokeBattle_Trainer
  attr_reader :trainertype, :name, :id, :metaID, :outfit, :language
  attr_reader :party, :badges, :money
  attr_reader :seen, :owned, :formseen, :formlastseen, :shadowcaught
  attr_reader :pokedex, :pokegear
  attr_reader :mysterygiftaccess, :mysterygift

  def self.copy(trainer)
    validate trainer => self
    ret = PlayerTrainer.new(trainer.name, trainer.trainertype)
    ret.id                    = trainer.id
    ret.character_ID          = trainer.metaID if trainer.metaID
    ret.outfit                = trainer.outfit if trainer.outfit
    ret.language              = trainer.language if trainer.language
    trainer.party.each { |p| ret.party.push(PokeBattle_Pokemon.convert(p)) }
    ret.badges                = trainer.badges.clone
    ret.money                 = trainer.money
    trainer.transfer_pokedex(ret.pokedex)
    ret.pokegear              = trainer.pokegear
    ret.mystery_gift_unlocked = trainer.mysterygiftaccess if trainer.mysterygiftaccess
    ret.mystery_gifts         = trainer.mysterygift.clone if trainer.mysterygift
    return ret
  end

  # Transfers old Pokédex data into the given Pokedex object.
  # @param pokedex [PlayerTrainer::Pokedex]
  def transfer_pokedex(pokedex)
    @seen.each_with_index do |seen, index|
      next unless seen
      pokedex.set_seen(index)
    end
    @owned.each_with_index do |owned, index|
      next unless owned
      pokedex.set_owned(index)
    end
    @formseen.each_with_index do |value, index|
      species_id = GameData::Species.try_get(index)&.species
      next if species_id.nil? || value.nil?
      pokedex.seen_forms[species_id] = [value[0].clone, value[1].clone]
    end
    @formlastseen.each_with_index do |value, index|
      species_id = GameData::Species.try_get(index)&.species
      next if species_id.nil? || value.nil?
      pokedex.last_seen_forms[species_id] = value.clone
    end
    if @shadowcaught
      @shadowcaught.each_with_index do |value, index|
        species_id = GameData::Species.try_get(index)&.species
        next if species_id.nil? || !value
        pokedex.owned_shadow[species_id] = value.clone
      end
    end
  end
end

# @deprecated Use {Trainer#remove_pokemon_at_index} instead. This alias is slated to be removed in v20.
def pbRemovePokemonAt(index)
  Deprecation.warn_method('pbRemovePokemonAt', 'v20', 'PlayerTrainer#remove_pokemon_at_index')
  return $Trainer.remove_pokemon_at_index(index)
end

# @deprecated Use {Trainer#has_other_able_pokemon?} instead. This alias is slated to be removed in v20.
def pbCheckAble(index)
  Deprecation.warn_method('pbCheckAble', 'v20', 'PlayerTrainer#has_other_able_pokemon?')
  return $Trainer.has_other_able_pokemon?(index)
end

# @deprecated Use {Trainer#all_fainted?} instead. This alias is slated to be removed in v20.
def pbAllFainted
  Deprecation.warn_method('pbAllFainted', 'v20', 'PlayerTrainer#all_fainted?')
  return $Trainer.all_fainted?
end

# @deprecated Use {Trainer#has_species?} instead. This alias is slated to be removed in v20.
def pbHasSpecies?(species, form = -1)
  Deprecation.warn_method('pbHasSpecies?', 'v20', 'PlayerTrainer#has_species?')
  return $Trainer.has_species?(species, form)
end

# @deprecated Use {Trainer#has_fateful_species?} instead. This alias is slated to be removed in v20.
def pbHasFatefulSpecies?(species)
  Deprecation.warn_method('pbHasSpecies?', 'v20', 'PlayerTrainer#has_fateful_species?')
  return $Trainer.has_fateful_species?(species)
end

# @deprecated Use {Trainer#has_pokemon_of_type?} instead. This alias is slated to be removed in v20.
def pbHasType?(type)
  Deprecation.warn_method('pbHasType?', 'v20', 'PlayerTrainer#has_pokemon_of_type?')
  return $Trainer.has_pokemon_of_type?(type)
end

# @deprecated Use {Trainer#get_pokemon_with_move} instead. This alias is slated to be removed in v20.
def pbCheckMove(move)
  Deprecation.warn_method('pbCheckMove', 'v20', 'PlayerTrainer#get_pokemon_with_move')
  return $Trainer.get_pokemon_with_move(move)
end

# @deprecated Use {Trainer#heal_party} instead. This alias is slated to be removed in v20.
def pbHealAll
  Deprecation.warn_method('pbHealAll', 'v20', 'PlayerTrainer#heal_party')
  $Trainer.heal_party
end
