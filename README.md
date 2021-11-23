## Running locally

Install *Ruby* and the gems for *Jekyll*. [How to do that](https://jekyllrb.com/docs/installation/).

1. Clone repository
2. `cd [there]`
3. `bundle install`
4. `bundle exec jekyll serve`
5. Open your browser to `http://localhost:4000`

Any changes you make will automatically build and you will be able to see these by refreshing your browser.

*Notes:*
- You will need to re-run `bundle exec jekyll serve` to see changes made in `_config.yml`.    
- pacman errors - install newer Ruby    
- servlet.rb:3:in `require': cannot load such file -- webrick (LoadError) -  

----