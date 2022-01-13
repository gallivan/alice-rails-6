json.array!(@view_points) do |view_point|
  json.extract! view_point, :id, :name, :note, :code
  json.url view_point_url(view_point, format: :json)
end
