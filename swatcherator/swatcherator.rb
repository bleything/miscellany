#!/usr/bin/env ruby

require 'rubygems'

require 'camping'
require 'camping/session'

Camping.goes :Swatcherator

COLORS = {
  :baby_blue    => '90c0d6', :baby_pink   => 'ffb2b6', :berry        => '942869',
  :black        => '0f0f0f', :brown       => '634228', :burnt_orange => 'cf4206',
  :chartreuse   => 'c4da39', :coral       => 'fc574e', :dark_green   => '264014',
  :dijon        => 'c97d02', :gold        => 'ffba30', :gray         => '4e5251',
  :leaf_green   => '437709', :light_green => '829c13', :mocha_brown  => 'ab875b',
  :navy         => '0e1e26', :olive       => '4f441d', :orange       => 'f26500',
  :peacock_blue => '028587', :purple      => '6b2e85', :red          => 'cc042f',
  :silver       => 'adb0ab', :slate_blue  => '136485', :soft_yellow  => 'fcd75d',
  :strawberry   => 'c90c19', :white       => 'f7f7f7'
}

DARKS = [
  :berry, :black, :brown,        :burnt_orange, :dark_green, :gray,       :leaf_green, 
  :navy,  :olive, :peacock_blue, :purple,       :red,        :slate_blue, :strawberry
]

NUMBER_OF_SWATCHES = 3

module Swatcherator ; include Camping::Session ; end

module Swatcherator::Controllers
  class Index < R '/'
    def get
      @swatches = COLORS.keys.sort_by{rand}[0..(NUMBER_OF_SWATCHES - 1)]
      
      @state[:enabled_colors] ||= COLORS.keys
      
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
            background: #333333;
            
            color: silver;
          }
          
          h1 {
            text-align: center;
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

          span {color:black}
          span.light {color: white}
          
          .clear { clear:both; }
          END
        end
      end
      
      body do
        h1 "Swatcherator"

        _color_selector

        self << yield
      end
    end
  end
  
  def index
    _swatches
  end
  
  private
  
  def _color_selector
    div.selector! do
      COLORS.keys.map(&:to_s).sort.each do |color|
        color = color.intern

        div.colorbox :style => "background: ##{COLORS[color]}" do
          opts = {:type => :checkbox, :name => color}
          opts.merge! :checked => true if @state[:enabled_colors].include? color
          
          input opts
        end
      end
    end

    div.clear nil # must pass some form of content into the div or nothing happens.
  end
  
  def _swatches
    div.swatches! do
      @swatches.each do |color|
        div.colorbox :style => "background: ##{COLORS[color]}" do
          color_name = color.to_s.split('_').map(&:capitalize).join(" ")

          span color_name, :class => (DARKS.include? color) ? 'light' : nil
        end
      end
    end
    
    div.clear nil
  end
end

def Swatcherator.create
  Camping::Models::Session.create_schema
end