require 'ruby2d'

set background: 'white'
set fps_cap: 10

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

class Snake
    attr_writer :direction

    def initialize
        @positions = [[2,0], [2,1], [2,2], [2,3]]
        @direction = 'down'
        @growing = false
    end

    def draw
        @positions.each do |position|
            Square.new(x:position[0] * GRID_SIZE, y:position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: 'green')
        end
    end

    def move
        if !@growing
            @positions.shift
        end
        case @direction
        when 'down'
            @positions.push(new_coords(head[0], head[1] + 1))
        when 'up'
            @positions.push(new_coords(head[0], head[1] - 1))
        when 'left'
            @positions.push(new_coords(head[0] - 1, head[1]))
        when'right'
            @positions.push(new_coords(head[0] + 1, head[1]))
        end
        @growing = false
    end

    def direction_to?(new_direction)
        case @direction
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
      @growing =true  
    end

    def hit_itself?
        @positions.uniq.length != @positions.length
    end

    private

    def new_coords(x,y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
        @positions.last
    end
end

class Game
    def initialize
        @points = 0
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
        @finish = false
    end

    def draw
        unless finish?
            Square.new(x: @food_x * GRID_SIZE, y: @food_y * GRID_SIZE, size: GRID_SIZE, color: 'red')
        end
        Text.new(message, color: 'blue', x:10, y:10, size: 20)
    end

    def snake_eat_food?(x, y)
       @food_x == x && @food_y == y 
    end

    def record_hit
        @points += 1
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
    end

    def finish
        @finish = true
    end

    def finish?
        @finish
    end

    private

    def message
        if finish?
            "Game over, you final points are: #{@points}, Press 'R' to restart."
        else
            "Points: #{@points}"
        end
    end
end

snake = Snake.new
game = Game.new

update do
    clear
    unless game.finish?
        snake.move
    end
    snake.draw
    game.draw

    if game.snake_eat_food?(snake.x, snake.y)
       game.record_hit
       snake.grow
    end
    
    if snake.hit_itself?
       game.finish 
    end
end
 on :key_down do |event|
    if['left', 'right', 'up', 'down'].include?(event.key)
        if snake.direction_to?(event.key)
            snake.direction = event.key
        end
    elsif event.key == 'r'
        snake = Snake.new
        game = Game.new
    end
 end
show