%% Minimal script to record data with the LM03 Lightmeter
% by Richard Schweitzer, adapted from Cambridge Research Systems demo scripts (thanks so much!)

% on Ubuntu, you'd have to do the following in advance:
% 1. symbolic link: sudo ln -s /dev/ttyACM0 /dev/ttyS101
% 2. permissions: sudo chmod 777 /dev/ttyS101


%% parameters for LM03 measurements
port = '/dev/ttyS101';  % Port for LM03
command_wait_time = 0.5;    % wait time after fwrite commands in seconds
samplePeriod = 500; % sample every xxx microseconds (min: 5)
resultingSampFreq = (1000*1000) / samplePeriod;
sampleNumber = 3999; % number of samples to take (max: 3999)
resultingSampDur = sampleNumber / resultingSampFreq; % in seconds
% resulting recording:
disp(['Starting LM03 recording at ', num2str(resultingSampFreq), ' Hz for ', num2str(resultingSampDur), 's ...']);
% arbitrary trial definitions
trial_nr = 1;
trial_amp = 8;
trial_vel = 1;
trial_dir = -1;


%% SETUP the LM03
delete(instrfindall);
delete(instrfind);
disp('Opening the LM03 device... ');
% create the serial port object and increase buffer to 32 kb
s1 = serial(port);
s1.InputBufferSize = 32768;
% open the port
fopen(s1);

% query for command options
disp('These are the command options for the LM03: ');
fwrite(s1,['?', 13]);
pause(command_wait_time); % wait until return is ready
result = fread(s1,s1.BytesAvailable); % read and display in command window
disp(char(result)');

% set sweep length (number of samples to take, max: 3999)
disp('Setting sweep length (number of samples)...');
eval(sprintf('fwrite(s1,[''L%i'', 13]);',sampleNumber));
pause(command_wait_time);
result = fread(s1,s1.BytesAvailable);
disp(char(result)');

% set sample period (in microseconds, min: 5)
disp('Setting sample period (time between samples in microseconds)...');
eval(sprintf('fwrite(s1,[''P%i'', 13]);',samplePeriod));
pause(command_wait_time);
result = fread(s1,s1.BytesAvailable);
disp(char(result)');


%% RECORDING with LM03
% send a command to record data
disp('Sending command to record data...');
fwrite(s1,['A', 13]);
record_start_here = GetSecs; % what time was this?
while s1.BytesAvailable<6
end
result = fread(s1,s1.BytesAvailable);
disp(char(result)');
disp('Now recording...');

% Here could be your presentation code
% ...

% Wait for LM03 data collection to end, that is, loop until data is ready (S 3 returned)
while 1
    fwrite(s1,['S', 13]);
    while s1.BytesAvailable<9
    end
    result = fread(s1,s1.BytesAvailable);
    if strfind(char(result)','3')
        % at what time the the LM03 recording end?
        record_end_here = GetSecs;
        record_duration = record_end_here - record_start_here;
        disp(['LM03 recording ended! Duration of recording measured: ', num2str(record_duration), ' seconds.']);
        disp(['The intended duration of the recording was: ', num2str(resultingSampDur), ' seconds.']);
        break;
    end
end


%% retrieve the data from LM03 and close the port
% retrieve data now
disp('Retrieving data now...');
fwrite(s1,['D', 13]);
fscanf(s1);
result = fscanf(s1);
% parse the data string
C = textscan(char(result)','%d %d','Delimiter',',');
% format nicely
t = (samplePeriod:samplePeriod:samplePeriod*sampleNumber)/1000;
data = [t' double(C{1}) double(C{2})];

% close the serial port
disp('Closing the LM03 device...');
fclose(s1);
disp('Done.')


%% Look at data
% add trial definitions to the recorded data
all_data = [];
all_data = [all_data;
    horzcat(repmat(trial_nr, size(data, 1), 1), ...   % which trial nr
            repmat(trial_amp, size(data, 1), 1), ...  % which amplitude
            repmat(trial_vel, size(data, 1), 1), ...  % which velocity
            repmat(trial_dir, size(data, 1), 1), ...  % which direction
    data)];                                           % resulting data

% make a figure
max_y = max(max(data(:,2:3)));
figure;
plot(data(:,1), data(:,2), '.-', ...
     data(:,1), data(:,3), '.--');
ylabel('Sensor measurements');
xlabel('Time [ms]');
ylim([0, max_y]);

% save csv of photodata, if you like
results_path = 'LM03_Data/';
photodata_savepath = [results_path, datestr(now,'yyyy_mm_dd_HH_MM_SS'), '.csv'];
csvwrite(photodata_savepath, all_data);

