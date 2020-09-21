class Hexagon < ApplicationRecord
  ADJUSTSENT_SIDES = [[0, 3], [1, 4], [2, 5], [3, 0], [4, 1], [5, 2]]
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_sides

  before_save :set_covid_cluster

  after_save :update_adjacent_hexagons_sides, if: -> { saved_change_to_sides? && sides.present? }

  def sides
    self[:sides].present? ? Hash[self[:sides].map { |k, v| [k.to_i, v] }] : nil
  end

  def validate_sides
    keys = sides.keys.map(&:to_i)
    values = sides.values.reject(&:nil?).map { |v| v[0] }
    valid_sides = sides.length == 6 && 
                  keys.uniq.size == keys.size && 
                  keys.select { |key| key < 0 || key > 5 }.blank? &&
                  values.uniq.size == values.size &&
                  Hexagon.where(name: [values]).size == values.size

    errors.add(:sides, 'are not valid') unless valid_sides
  end

  def neighbours
    if sides.present?
      sides.select { |k, v| v.present? }.map { |k, v| "#{k}#{v[0]}"}
    end
  end

  def set_covid_cluster
    self.is_covid_cluster = neighbours.present?
  end

  def can_become_covid_free?
    values = sides.values.reject(&:nil?).map { |v| v[0] }
    return true if values.size <= 1

    neighbouring_clusters = get_neighbouring_clusters(values)
    
    neighbouring_clusters.each do |cluster|
      return false if !is_path_between_cluster?(cluster)
    end

    return true
  end

  def update_adjacent_hexagons_sides
    sides.each do |k, v|
      if v.present?
        hexagon = Hexagon.find_by(name: v[0])
        hexagon_sides = hexagon.sides
        if hexagon_sides[v[1]].nil?
          hexagon_sides[v[1]] = [name, k.to_i]
          hexagon.sides = hexagon_sides
          hexagon.save!
        end
      end
    end
  end

  private

  def get_neighbouring_clusters(values)
    neighbouring_clusters = []
    values.each_with_index do |value, index|
      i = index + 1
      while i < values.size
        neighbouring_clusters << [value, values[i]].sort
        i += 1
      end
    end
    neighbouring_clusters.uniq
  end

  def is_path_between_cluster?(cluster)
    source = cluster[0]
    destination = cluster[1]
    hexagon = Hexagon.find_by(name: source)
    values = hexagon.sides.values.reject(&:nil?).map { |v| v[0] }
    return true if values.include?(destination)

    values.each do |value|
      if value != name
        return is_path_between_cluster?([value, destination])
      end
    end
    return false
  end
end
