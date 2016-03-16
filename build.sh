elm make src/Main.elm --output build/index.html
cp media/* build
git checkout gh-pages
cp build/* .
git add .
git commit -m 'update gh-pages'
git push origin gh-pages
