#!/usr/bin/env ruby

require 'rubygems'

require 'camping'
require 'camping/session'

Camping.goes :Swatcherator

COLORS = {
  :baby_blue => {
    :name    => 'Baby Blue',
    :hexcode => '90c0d6',
    :class   => 'light',
    :enabled => true,
  },

  :baby_pink => {
    :name    => 'Baby Pink',
    :hexcode => 'ffb2b6',
    :class   => 'light',
    :enabled => true,
  },

  :berry => {
    :name    => 'Berry',
    :hexcode => '942869',
    :class   => 'dark',
    :enabled => true,
  },

  :black => {
    :name    => 'Black',
    :hexcode => '0f0f0f',
    :class   => 'dark',
    :enabled => true,
  },

  :brown => {
    :name    => 'Brown',
    :hexcode => '634228',
    :class   => 'dark',
    :enabled => true,
  },

  :burnt_orange => {
    :name    => 'Burnt Orange',
    :hexcode => 'cf4206',
    :class   => 'dark',
    :enabled => true,
  },

  :chartreuse => {
    :name    => 'Chartreuse',
    :hexcode => 'c4da39',
    :class   => 'light',
    :enabled => true,
  },

  :coral => {
    :name    => 'Coral',
    :hexcode => 'fc574e',
    :class   => 'light',
    :enabled => true,
  },

  :dark_green => {
    :name    => 'Dark Green',
    :hexcode => '264014',
    :class   => 'dark',
    :enabled => true,
  },

  :dijon => {
    :name    => 'Dijon',
    :hexcode => 'c97d02',
    :class   => 'light',
    :enabled => true,
  },

  :gold => {
    :name    => 'Gold',
    :hexcode => 'ffba30',
    :class   => 'light',
    :enabled => true,
  },

  :gray => {
    :name    => 'Gray',
    :hexcode => '4e5251',
    :class   => 'dark',
    :enabled => true,
  },

  :leaf_green => {
    :name    => 'Leaf Green',
    :hexcode => '437709',
    :class   => 'dark',
    :enabled => true,
  },

  :light_green => {
    :name    => 'Light Green',
    :hexcode => '829c13',
    :class   => 'light',
    :enabled => true,
  },

  :mocha_brown => {
    :name    => 'Mocha Brown',
    :hexcode => 'ab875b',
    :class   => 'light',
    :enabled => true,
  },

  :navy => {
    :name    => 'Navy',
    :hexcode => '0e1e26',
    :class   => 'dark',
    :enabled => true,
  },

  :olive => {
    :name    => 'Olive',
    :hexcode => '4f441d',
    :class   => 'dark',
    :enabled => true,
  },

  :orange => {
    :name    => 'Orange',
    :hexcode => 'f26500',
    :class   => 'light',
    :enabled => true,
  },

  :peacock_blue => {
    :name    => 'Peacock Blue',
    :hexcode => '028587',
    :class   => 'dark',
    :enabled => true,
  },

  :purple => {
    :name    => 'Purple',
    :hexcode => '6b2e85',
    :class   => 'dark',
    :enabled => true,
  },

  :red => {
    :name    => 'Red',
    :hexcode => 'cc042f',
    :class   => 'dark',
    :enabled => true,
  },

  :silver => {
    :name    => 'Silver',
    :hexcode => 'adb0ab',
    :class   => 'light',
    :enabled => true,
  },

  :slate_blue => {
    :name    => 'Slate Blue',
    :hexcode => '136485',
    :class   => 'dark',
    :enabled => true,
  },

  :soft_yellow => {
    :name    => 'Soft Yellow',
    :hexcode => 'fcd75d',
    :class   => 'light',
    :enabled => true,
  },

  :strawberry => {
    :name    => 'Strawberry',
    :hexcode => 'c90c19',
    :class   => 'dark',
    :enabled => true,
  },

  :white => {
    :name    => 'White',
    :hexcode => 'f7f7f7',
    :class   => 'light',
    :enabled => true,
  },  
}

NUMBER_OF_SWATCHES = 3

module Swatcherator ; include Camping::Session ; end

module Swatcherator::Controllers
  class Index < R '/'
    def get
      @state[:colors] ||= COLORS
      
      @state[:colors][:baby_pink][:enabled] = false
      @state[:colors][:berry][:enabled] = false
      @state[:colors][:coral][:enabled] = false
      @state[:colors][:white][:enabled] = false
      @state[:colors][:purple][:enabled] = false
      @state[:colors][:baby_blue][:enabled] = false
      @state[:colors][:red][:enabled] = false
      @state[:colors][:black][:enabled] = false
      # @state[:colors][:purple][:enabled] = false
      
      @swatches = @state[:colors].select {|c,v| v[:enabled]}.sort_by {rand}[0..(NUMBER_OF_SWATCHES - 1)]
      render :index
    end
  end
  
  class ColorSelector < R '/selector'
    def get
      redirect(R Index)
    end
    
    def post
    end
  end
end

module Swatcherator::Views
  def layout
    html do
      head do
        title { 'Swatcherator' }
        style do
          <<-END
          body {
            margin: 0;
            font-family: sans-serif;
            background: #444444;
            color: silver;
          }

          #footer, #header {
            background: #333333;
            color: #cccccc;
            text-align: center;
            width: 100%;
          }

          #header {
            font-size: 2em;
            margin-bottom: 1em;
            padding: 0.3em 0 0.15em 0;
          }

          #footer {
            padding: 0.5em 0 0.2em 0;
            font-size: 0.8em;
            margin-top: 1em;
            position: absolute;
            bottom: 0;
          }

          #footer a, #header a {
            color: #d88722;
          }
          
          #container, #selector, #swatches, #instructions {
            margin: auto;
          }
          
          #container {
            width: 95%;
          }
          
          #selector {
            width: 40%
          }
          
          #swatches, #instructions {
            padding-top: 4em;
          }
          
          #swatches {
            width: 75%;
          }
          
          #instructions {
            text-align: center;
            width: 60%;
          }
          
          div.colorbox {
            float: left;
            text-align: center;
          }
          
          #selector div.colorbox {
            padding: 10px;
            margin-right: 10px;
            margin-bottom: 10px;
          }
          
          #selector div.light {
            border: 1px solid black;
          }
          
          #selector div.dark {
            border: 1px solid white;
          }
          
          div.note {
            text-align: center;
            font-size: .8em;
          }
          
          #swatches div.colorbox {
            width: #{100 / NUMBER_OF_SWATCHES}%;
            height: 200px;
          }
          
          div span {
            width: 100%;
            height: 100%;
            text-align: center;
            
            position: relative;
            top: 45%;
          }
          
          span.light {color:black}
          span.dark  {color: white}
          
          .clear { clear:both; }
          END
        end
      end
      
      body do
        div.header! "Swatcherator"

        div.container! do
          _color_selector

          self << yield
        end
        
        div.footer! "Swatcherator Copyright 2007 Ben Bleything.  All Rights Reserved.  Color Schemes are not included under this copyright."
      end
    end
  end
  
  def index
    div.instructions! do
      h2 "You're ready to start mixing up colors with Swatcherator!"
      
      p "To get started, just click the big Go button above.  You can also pick which colors to mix by checking or unchecking them in the boxes above.  You can bookmark any swatch to look at it later."
    end
    
    _swatches
  end
  
  private
  
  def _color_selector
    div.selector! do
      # sort colors in alphabetical order.  There's probably a better way.  I'm tired.
      @state[:colors].keys.map(&:to_s).sort.map(&:intern).each do |code|
        color = @state[:colors][code]
        
        klass = "colorbox #{color[:class]}"

        div :style => "background: ##{color[:hexcode]}", :class => klass do
          opts = {:type => :checkbox, :name => 'colors[]', :value => code}
          opts.merge! :checked => true if color[:enabled]
          
          input opts
        end
      end
    end

    div.clear nil # must pass some form of content into the div or nothing happens.

    num_colors   = @state[:colors].size
    num_enabled  = @state[:colors].select {|k,v| v[:enabled]}.size
    combinations = factorial(num_enabled) / (factorial(NUMBER_OF_SWATCHES) * factorial(num_enabled - NUMBER_OF_SWATCHES))
    div.note "#{num_enabled} colors enabled out of #{num_colors}, yielding #{combinations} possible color combinations."
  end
  
  def _swatches
    div.swatches! do
      @swatches.each do |code, color|
        div.colorbox :style => "background: ##{color[:hexcode]}" do
          span color[:name], :class => color[:class]
        end
      end
    end
    
    div.clear nil
  end
  
  def factorial(n) 
    return n if n == 1
    return n * factorial( n - 1 )
  end
end

def Swatcherator.create
  Camping::Models::Session.create_schema
end