
service "whatismyip", {
	consumes "php", {}

	generate: =>
		domainName = @\getDomainName! or "@"
		directory = "/srv/www/#{domainName}"

		@\createDirectory directory
		@\writeTemplate "whatismyip", "#{directory}/index.php"

		os.execute "chown -R nginx:nginx '#{@context.outputDirectory}#{directory}'"
}

