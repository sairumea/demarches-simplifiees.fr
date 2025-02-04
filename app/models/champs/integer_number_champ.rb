class Champs::IntegerNumberChamp < Champ
  validates :value, numericality: {
    only_integer: true,
    allow_nil: true,
    allow_blank: true,
    message: -> (object, _data) {
      # i18n-tasks-use t('errors.messages.not_an_integer')
      "« #{object.libelle} » " + object.errors.generate_message(:value, :not_an_integer)
    }
  }

  def for_export
    processed_value
  end

  def for_api
    processed_value
  end

  private

  def processed_value
    return if invalid?

    value&.to_i
  end
end
