class HexagonsController < ApplicationController

  before_action :set_hexagon, only: [:show, :remove]

  def new
    @hexagon = Hexagon.new
  end

  def show
  end

  def create
    @hexagon = Hexagon.new(name: hexagon_params[:name])
    @hexagon.sides = get_sides
    if @hexagon.valid?
      @hexagon.save!
      redirect_to hexagon_path(name: @hexagon.name)
    else
      @hexagon.sides = nil
      @errors = @hexagon.errors.full_messages
      render :new
    end
  end

  def remove
    if @hexagon.can_become_covid_free?
      @hexagon.sides.each do |side, values|
        if values.present?
          h = Hexagon.find_by(name: values[0])
          sides = h.sides
          sides[values[1]] = nil
          h.sides = sides
          h.save!
        end
      end
      @hexagon.update(sides: { 0 => nil, 1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil })
      redirect_to hexagon_path(name: @hexagon.name)
    else
      redirect_to hexagon_path(name: @hexagon.name), flash: { error: "Can not become covid free" }
    end
  end

  private

  def set_hexagon
    @hexagon = Hexagon.find_by(name: params[:name])
    @errors = "Invalid hexagon name" unless @hexagon
  end

  def get_sides
    sides = { 0 => nil, 1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil }
    if hexagon_params[:sides].present?
      sides_param = hexagon_params[:sides].split(',').map(&:strip)
      sides_param.each do |param|
        side_index = param.split('#')[0].to_i - 1
        values = param.split('#')[1].split('$')
        sides[side_index] = [values[0], values[1].to_i - 1]
        sides = update_adjacent_sides(sides, side_index, values[0], values[1].to_i - 1)
      end
    end
    sides
  end

  def update_adjacent_sides(sides, new_side_index, hexagon_name, hexagon_side_index)
    current_hexagon = Hexagon.find_by(name: hexagon_name)
    previous_index = get_previous_index(new_side_index)
    next_index = get_next_index(new_side_index)

    hexagon_previous_index = get_previous_index(hexagon_side_index)
    hexagon_next_index = get_next_index(hexagon_side_index)

    if current_hexagon.sides[hexagon_previous_index].present?
      sides = update_sides(sides, next_index, current_hexagon.sides[hexagon_previous_index])
    end

    if current_hexagon.sides[hexagon_next_index].present?
      sides = update_sides(sides, previous_index, current_hexagon.sides[hexagon_next_index])
    end
    sides
  end

  def update_sides(sides, side_index, side)
    hexagon = Hexagon.find_by(name: side[0])
    previous_index = get_previous_index(side[1])
    sides = update_side(sides, side_index, previous_index, hexagon)

    next_index = get_next_index(side[1])
    sides = update_side(sides, side_index, next_index, hexagon)

    sides
  end

  def update_side(sides, side_index, adjacent_hexagon_index, adjacent_hexagon)
    if sides[side_index].nil? && adjacent_hexagon.sides[adjacent_hexagon_index].nil? && Hexagon::ADJUSTSENT_SIDES.find_index([side_index, adjacent_hexagon_index])
      sides[side_index] = [adjacent_hexagon.name, adjacent_hexagon_index]
      sides = update_adjacent_sides(sides, side_index, adjacent_hexagon.name, adjacent_hexagon_index)
    end
    sides
  end

  def get_next_index(index)
    index == 5 ? 0 : index + 1
  end

  def get_previous_index(index)
    index == 0 ? 5 : index - 1
  end

  def hexagon_params
    params.require(:hexagon).permit(:name, :sides)
  end
end
