
disp('First navigate to where you want the Chebfun website''s folder to be')
disp('located, then run this script from there. For example, to set up the')
disp('site at  ~/chebfun/chebsite,  copy this script to the folder "chebfun".')
disp('Your current location is'), x = pwd; disp(['   ' x])
disp(' ')
goahead = input('Do you wish to set up the site here? y/n: ', 's');

if length(goahead) > 0 && ( goahead(1) == 'y' || goahead(1) == 'Y' ),

    % These options are necessary to ensure that the proper version of the
    % libcurl library is used. Otherwise you'll get a "protocol not supported"
    % error when trying to clone the git repos.
    opts = '';
    if ismac
        opts = 'DYLD_LIBRARY_PATH=/usr/lib';
    elseif isunix
        opts = 'LD_LIBRARY_PATH=/usr/lib64:/usr/lib';
    else
        disp('Looks like you''re running on a windows system.');
        disp('The website setup may not work for you.')
    end


    % Clone the chebsite repo.
    mkdir chebsite
    system([opts ' git clone https://github.com/chebfun/chebsite.git chebsite']);

    % Clone the build repo.
    mkdir 'chebsite/_build'
    system([opts ' git clone https://github.com/chebfun/chebfun.github.io.git "chebsite/_build"']);

    % Clone the examples repo.
    mkdir examples
    system([opts ' git clone https://github.com/chebfun/examples.git examples']);

    % Clone the guide repo.
    mkdir guide
    system([opts ' git clone https://github.com/chebfun/guide.git guide']);

    % Install the necessary python modules.
    system('pip install --user MarkupSafe Jinja2 PyYAML Markdown');

end
