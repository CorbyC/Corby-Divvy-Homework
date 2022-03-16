defmodule HomeworkWeb.PaginationHelper do

  @doc """
  Returns a paginated set of objects recieved
  """
  def paginate(objects, args) do
    %{limit: limit, skip: skip} = getParams(objects, args)
    {:ok, Enum.slice(objects, skip, limit)}
  end

  @doc """
  Gets limit and skip from args. Defaults to limit:Enum.Count and skip:0 if not recieved.
  """
  def getParams(objects, args) do
    Map.merge(%{limit: Enum.count(objects), skip: 0}, args) # merge with default values to get values always
  end

end
