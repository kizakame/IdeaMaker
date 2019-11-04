
    get '/models1' do
      @models = []
      column_names = User.column_names
      rows = User.all
      model = {"table_name": "history", "model_name": "history", "column_names": column_names, "rows": rows}
      @models.push(model)
      erb :aldy_show_sqlite3_tables
    end

    get '/models2' do
      @models = []
      column_names = Task.column_names
      rows = Task.all
      model = {"table_name": "history", "model_name": "history", "column_names": column_names, "rows": rows}
      @models.push(model)
      erb :aldy_show_sqlite3_tables
    end