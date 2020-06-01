clear; close all;

%% Parameters
sampleFolder = '.\samples'; % Folder with original samplesNumber
processedSamplesFolder = '.\cropped_samples'; % Folder with cropped images and hitograms
sampleName = 'SuperNova01.jpg'; % Image to analyze
samplesNumber = [3 3]; % Matrix for original image segmentation (***increase
                       % dimentions to increase the number of samples ***)
%%

%% Adding paths
addpath(sampleFolder);
%%

%%
originalImage = imread(sampleName); % opening image from sampleFolder
grayScaleImage = rgb2gray(originalImage); % converting colored image to gray scale
imgGrayScaleName = [sampleFolder, '\GS', sampleName]; % creating string for gray scale image name
imwrite(grayScaleImage, imgGrayScaleName); % saves gray scale image in sampleFolder

% energyCalc function calculates energy for each segment of original image
% and saves all data in a folder named according with the original sample
% inside the processedSamplesFolder directory.
energyCalc(grayScaleImage, sampleName, processedSamplesFolder, samplesNumber); 
%%

%% energyCalc function 
function energyCalc(I, sampleName, processedSamplesFolder, samplesNumber)
    
    % Deleting folder with old segments
    dirName = erase(sampleName,'.jpg');
    F = [processedSamplesFolder, '\', dirName];
    if exist(F, 'dir')
        rmdir(F, 's');
    end
    % creating new empty folder for new segments (subcrops and histograms)
    mkdir(F);
    
    % Setting size of crops based on samplesNumber dimension and size of
    % original image
    [height, width] = size(I);
    heightStep = floor(height/samplesNumber(1));
    widthStep = floor(width/samplesNumber(2));
    
    % cropping and calculating segments energy based on each segment
    % histogram
    for i=1:samplesNumber(1)
        for j=1:samplesNumber(2)
            cropX = widthStep*(i-1);
            cropY =  heightStep*(j-1);
            Icropped = imcrop(I,[cropX cropY widthStep heightStep]); % cropping segments
            h = histogram(Icropped, 256);  % histogram of current segment
            axis([0 255 0 inf]) % limiting axes of histogram (0 to 255 on X, 0 to inf on Y)
            
            % Calculating energy of segment
            energy=0; 
            for k = 1:256
                energy = energy + h.Values(k)*(k^2);
            end
            energy = energy/1e6;
            
            % Creating a text box on histogram graph to plot the energy
            % value
            dim = [.5 .6 .3 .3];
            str = ['Energy = ', int2str(energy), ' x 10^6'];
            a = annotation('textbox',dim,'String',str,'FitBoxToText','on');
            
            % Creating names for segment and respective histogram
            cropName = [F,'\crop', int2str(j), 'x', int2str(i), '.jpg'];
            histName = [F,'\hist', int2str(j), 'x', int2str(i), '.jpg'];
            
            imwrite(Icropped, cropName); % Writing crop in cropped_samples folder
            saveas(gcf, histName); % Saving histogram in cropped_samples folder
            delete(a); % Empting text box on histogram graph
        end
    end
end
