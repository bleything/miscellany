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
      
      @swatches = @state[:colors].select {|c,v| v[:enabled]}.sort_by {rand}[0..(NUMBER_OF_SWATCHES - 1)]
      render :index
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
            margin-bottom: 2em;
            padding: 0.3em 0 0.15em 0;
          }

          #footer {
            padding: 0.5em 0 0.2em 0;
            font-size: 0.8em;
            margin-top: 2em;
            position: absolute;
            bottom: 0;
          }

          #footer a, #header a {
            color: #d88722;
          }
          
          #container {
            margin: auto;
            width: 95%;
          }
          
          #selector {
            width: 40%;
            margin: auto;
          }
          
          #swatches {
            margin: auto;
            width: 75%;
            
            padding-top: 4em;
          }
          
          div.colorbox {
            float: left;
            text-align: center;
          }
          
          #selector div.colorbox {
            padding: 10px;
            margin-right: 10px;
            margin-bottom: 10px;
            
            border: 1px solid white;
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
    _swatches
  end
  
  private
  
  def _color_selector
    div.selector! do
      # sort colors in alphabetical order.  Probably a better way.  I'm tired.
      @state[:colors].keys.map(&:to_s).sort.map(&:intern).each do |code|
        color = @state[:colors][code]

        div.colorbox :style => "background: ##{color[:hexcode]}" do
          opts = {:type => :checkbox, :name => code}
          opts.merge! :checked => true if color[:enabled]
          
          input opts
        end
      end
    end

    div.clear nil # must pass some form of content into the div or nothing happens.
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
end

def Swatcherator.create
  Camping::Models::Session.create_schema
end