function shuf_data = phase_shuf_group_data(real_data)
%this function randomize the signal phase with *different* randomization across subjects (columns)
%and same randomization of time/freq sampls across voxels.
%shuf_data" : signal_time_samples X subjs X vxls

[Nsamp, Nsubjs, Nvxls] = size(real_data);  %extract number of samples and number of signals

%transform the vectors-to-be-scrambled to the frequency domain
Fx = fft(real_data,[],1);
clear real_data

% identify indices of positive and negative frequency components of the fft
% we need to know these so that we can symmetrize phase of neg and pos freq
if mod(Nsamp,2) == 0
    posfreqs = 2:(Nsamp/2);
    negfreqs = Nsamp : -1 : (Nsamp/2)+2;
else
    posfreqs = 2:(Nsamp+1)/2;
    negfreqs = Nsamp : -1 : (Nsamp+1)/2 + 1;
end

x_amp = abs(Fx);  %get the amplitude of the Fourier components
x_phase = atan2(imag(Fx), real(Fx)); %get the phases of the Fourier components [NB: must use 'atan2', not 'atan' to get the sign of the angle right]
J = sqrt(-1);  %define the vertical vector in the complex plane


% shuf_data = zeros(Nsamp,Nsubjs,Nvxls);
rand_phase = zeros(Nsamp,Nsubjs,Nvxls);  %will cotnain the randomized phases for each input channel on each bootstrap
sym_phase = zeros(Nsamp,Nsubjs,Nvxls);   %will contain symmetrized randomized phases for each bootstrap
[~,index] = sort(rand(Nsamp,Nsubjs)); %generate a set of column vectors each of which is a separate random permutation

for s = 1:Nsubjs  
    rand_phase(:,s,:)=x_phase(index(:,s),s,:);
end


sym_phase(posfreqs,:,:) = rand_phase(posfreqs,:,:) - rand_phase(negfreqs,:,:); %symmetrize permuted phases so phi(w) = -phi(-w)
sym_phase(negfreqs,:,:) = rand_phase(negfreqs,:,:) - rand_phase(posfreqs,:,:); %this quarantees the iFFT is real

z = x_amp.*exp(J.*sym_phase); %generate (symmetric)-phase-scrambled Fourier components
shuf_data = ifft(z); %invert the fft to generate a phase-scrambled version of the data
end
