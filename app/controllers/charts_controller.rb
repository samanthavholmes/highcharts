class ChartsController < ApplicationController
  include ChartsHelper

  def index
    @chart = create_chart
  end
end
