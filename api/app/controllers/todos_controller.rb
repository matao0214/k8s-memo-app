# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[update destroy]

  # GET /todos
  def index
    @todos = Todo.all.order(created_at: :desc)
    if @todos.empty?
      render json: { message: 'No todos found' }, status: :not_found
    else
      render json: @todos
    end
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)
    if @todo.save!
      render json: @todo, status: :created, location: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todos/:id
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = Todo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def todo_params
    params.require(:todo).permit(:title, :completed)
  end
end
