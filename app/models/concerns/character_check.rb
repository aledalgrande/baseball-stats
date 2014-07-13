module CharacterCheck
  extend ActiveSupport::Concern

  module ClassMethods
    def check_invalid_characters(*strings)
      encoding_options = { invalid: :replace, undef: :replace, replace: '', universal_newline: true }

      strings.each do |string|
        return true if string.encode(Encoding.find('ASCII'), encoding_options).blank?
      end

      return false
    end
  end
end