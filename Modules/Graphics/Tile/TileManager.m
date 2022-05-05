classdef TileManager
    % Class to load and manage the sprite tiles used to display the game.
    
    properties (Access=private)
        % List of all tiles currently loaded
        tileAtlas
    end
    
    methods
        function this = TileManager()
            % Class initialiser

            % Load sprite atlas
            atlas = imread("assets/atlas.png");
            atlasWidth = size(atlas, 2) / 32;
            atlasHeight = size(atlas, 1) / 32;

            tAtlas = zeros(32, 32, 3, atlasWidth * atlasHeight, "uint8");

            % Extract each tile from the atlas and store it in the
            % tileAtlas variable
            for row = 0:atlasHeight-1
                for col = 0:atlasWidth-1
                    % Get all the pixels and put them into tileAtlas
                    tAtlas(:,:,:,col + row*atlasWidth + 1) =...
                        atlas(row*32+1:row*32+32,col*32+1:col*32+32,:)/64;
                end
            end

            % Set the tile atlas here instead of earlier since accessing
            % class members has more overhead
            this.tileAtlas = tAtlas;
        end
        
        function tile = GetTile(obj, tileIndex)
            % Get a tile from the atlas

            tile = obj.tileAtlas(:,:,:,tileIndex + 1);
        end
    end
end

