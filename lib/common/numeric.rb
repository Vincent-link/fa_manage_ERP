module Common
  class Numeric
    def self.divide(numerator, denominator)
      return 0 if denominator.zero?
      numerator * 1.0 / denominator
    end
  end
end