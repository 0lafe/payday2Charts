module Helpers
  def read_table(selector)
    table = find(selector)

    headers = table.all('thead th').map(&:text)

    table.all('tbody tr').map do |row|
      row_data = row.all('td').map(&:text)
      Hash[headers.zip(row_data)]
    end
  end

  def select2_select(selector, value)
    within(selector) do
      find(".select2-selection").click
    end
    within(".select2-results", match: :first) do
      find('li', text: value).click
    end
  end
end