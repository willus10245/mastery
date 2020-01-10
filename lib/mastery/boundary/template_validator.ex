defmodule Mastery.Boundary.TemplateValidator do
  alias Mastery.Boundary.Validator

  def errors(fields) when is_list(fields) do
    fields = Map.new(fields)

    []
    |> Validator.require(fields, :name, &validate_name/1)
    |> Validator.require(fields, :category, &validate_name/1)
    |> Validator.optional(fields, :instructions, &validate_instructions/1)
    |> Validator.require(fields, :raw, &validate_raw/1)
    |> Validator.require(fields, :generators, &validate_generators/1)
    |> Validator.require(fields, :checker, &validate_checker/1)
  end

  def errors(_fields) do
    [{nil, "A keyword list of fields is required"}]
  end

  def validate_name(name) when is_atom(name), do: :ok
  def validate_name(_name), do: {:error, "must be an atom"}

  def validate_instructions(instructions) when is_binary(instructions), do: :ok
  def validate_instructions(_instructions), do: {:error, "must be a string"}

  def validate_raw(raw) when is_binary(raw) do
    raw
    |> String.match?(~r/\S/)
    |> Validator.check({:error, "can't be blank"})
  end

  def validate_raw(_raw) do
    {:error, "must be a string"}
  end

  def validate_generators(generators) when is_map(generators) do
    generators
    |> Enum.map(&validate_generator/1)
    |> Enum.reject(&(&1 == :ok))
    |> case do
      [] ->
        :ok

      errors ->
        {:errors, errors}
    end
  end

  def validate_generators(_generators) do
    {:error, "must be a map"}
  end

  def validate_generator({name, generator})
      when is_atom(name) and is_list(generator) do
    (generator != [])
    |> Validator.check({:error, "can't be empty"})
  end

  def validate_generator({name, generator})
      when is_atom(name) and is_function(generator, 0) do
    :ok
  end

  def validate_generator(_generator) do
    {:error, "must be an atom to list or function pair"}
  end

  def validate_checker(checker) when is_function(checker, 2), do: :ok
  def validate_checker(_checker), do: {:error, "must be an arity 2 function"}
end
