require 'json'

file = JSON.parse(File.open('Various_Payday_Strings_2.txt').read)
file2 = JSON.parse(File.open('app/services/localizations.json').read)

file.keys.each do |key|
	file2[key] = file[key] unless file2[key]
end

File.write('localizations_2.json', JSON.dump(file2))