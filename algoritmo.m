clear all;
close all;

figure;
for nim = 1:125
    tic;
    img = imread(['../DRIMDB/Good/drimdb_good (',num2str(nim),').jpg']);
    imgOriginal = img;
    img =img(:,:,2);
    Nx = size(img,1);
    Ny = size(img,2);
    px_total = Nx*Ny;    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Threshold macula y disco.       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    th_disco = px_total*0.0015;
    th_macula = px_total*0.005;
    th_vasos = px_total*0.03;
    [a(nim),sigma(nim),mu(nim)] = test_param_gaus(img);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Filtro de alta y bajas frecuencias
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Filtro de bajas frecuencias
    ft = fftshift(fft2(img));
    [cL1, cH1] = getfilters(10,Nx, Ny);
    l_ft = ft .* cL1;    
    %Filtro de altas frencuencias
    [cL1, cH1] = getfilters(20,Nx, Ny);
    [cL2, cH2] = getfilters(150,Nx, Ny);
    cBP = cH1.*cL2;
    cBP = imgaussfilt(double(cBP),3);
    h_ft = ft .* cBP;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   reconstrucción y normalización
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    low_filtered_image = ifft2(ifftshift(l_ft));
    high_filtered_image = ifft2(ifftshift(h_ft));
    low_f = uint8(abs(low_filtered_image));
    high_f = uint8(abs(high_filtered_image));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Búsqueda del disco optico
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D1= 40;%Tamaño de cuadro de busqueda en filtro de altas frecuencias
    
    %busqueda del disco optico
    A = zeros(size(img));
    %threshold de band pass
    std_high = std(reshape(real(high_filtered_image),Nx*Ny,1));
    A(find(-(real(high_filtered_image))>std_high)) =1;
    
    A(1:D1,:)= 0;A(:,end-D1:end)=0;
    A(:,1:D1)= 0;A(end-D1:end,:)=0;
    suma_hp(nim) = sum(sum(A));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Sumatoria vertical para la busqueda del disco optico
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    num = 12;%tamaño del cuadro para hacer la sumatoria
    C= zeros(num,1);
    nx2 = floor(Nx/num);
    ny2 = floor(Ny/num);
    for col =1: num
        C(col)= sum(sum(A( 50:end-50, (col-1)*ny2+1 : col*ny2)));
    end
    
    x = [0:num-1]*nx2+nx2/2;
    y = [0:num-1]*ny2+ny2/2;

    [a b] = max(C);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Busqueda del circulo
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img_disco = zeros(size(img));
    ind3 = [round(y(max(b-1,1))):round(y(min(b+1,12)))];

    thr_disco = 0.95*max(max(low_f(D1:end-D1,ind3)));
    img_disco(:,ind3)  =(low_f(:,ind3) >thr_disco);
    ind1=find(img_disco ==1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Busqueda del centro del disco optico %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ind1x = zeros(length(ind1),1);
    ind1y = zeros(length(ind1),1);

    for n1 = 1:length(ind1)
        ind1x(n1) = floor(ind1(n1)/Nx)+1;
        ind1y(n1) = ind1(n1)-floor(ind1(n1)/Nx)*Nx;
    end
    posy_disco = floor(median(ind1y));
    posy_disco_x = floor(median(ind1x));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         Busqueda de la macula          %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img_macula = zeros(size(img));
    D = 60;
    ind = max(posy_disco - 90,D):min(posy_disco+90,size(img,1)-D);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Lugar por el que se busca la macula Izquierda o derecha     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if posy_disco_x > size(img,2)/2
        ind_x = max(posy_disco_x - 350,D):min(posy_disco_x-150,size(img,2)-D);
    else
        ind_x = max(posy_disco_x+150,D):min(posy_disco_x+350,size(img,2)-D);
    end
    
    thr_macula = min(min((low_f(ind,ind_x))))*1.1;
    img_macula(ind,ind_x) = (low_f(ind,ind_x)<thr_macula);

    size_macula(nim) = sum(sum(img_macula));
    size_disco(nim) = sum(sum((img_disco)));
    
    if (size_disco(nim) > th_disco*0.25) && (size_disco(nim)< th_disco*1.85)%1.5
        disco_detected(nim) = 1;
        if (size_macula(nim) > th_macula*0.15) && (size_macula(nim)<th_macula*2) 
            macula_detected(nim) = 1;
        end    
    end
    
    im2 = img_disco+img_macula;
    imgTemp = im2double(imgOriginal);
    im3 = imgTemp .* im2;
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   imagen en el canal verde
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,1);
    imagesc(imgOriginal);axis('equal')
    title(sprintf('min = %1.1f, mean %1.1f, sigma %1.1f',min(min((low_f(ind,ind_x)))),mean(mean((low_f(ind,ind_x)))),sigma(nim)))
    hold on; contour(img_disco,'r','LineWidth',1.5);
    hold on; contour(img_macula,'c','LineWidth',1.5);
    hold on;plot(y(max(b-1,1))*[1 1],[1 Nx],'w')
    hold on;plot(y(min(b+1,num))*[1 1],[1 Nx],'w')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Plot del filtro de alta frecuencia  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,4);
    imagesc(A);
    hold on;plot(y(max(b-1,1))*[1 1],[1 Nx],'w')
    hold on;plot(y(min(b+1,num))*[1 1],[1 Nx],'w')
    axis('equal')
    title(nim)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Filtro de Baja frecuencia           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,3);
    imagesc(low_f);
    hold on; contour(im2,'w')
    hold on;plot(y(max(b-1,1))*[1 1],[1 Nx],'w')
    hold on;plot(y(min(b+1,num))*[1 1],[1 Nx],'w')
    hold off
    axis('equal')
    caxis([min(min((low_f(ind,ind_x)))) 200])
    hold on;
    plot([ind_x(1) ind_x(end)],ind(1)*[1 1],'y')
    plot([ind_x(1) ind_x(end)],ind(end)*[1 1],'y')
    plot(ind_x(end)*[1 1], [ind(1) ind(end)],'y')
    plot(ind_x(1)*[1 1], [ind(end) ind(1)],'y')
    hold off
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Plot de la sumatoria                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,2);
    bar(y,C)
    hold on;plot(y(max(b-1,1))*[1 1],[1 max(C)],'r')
    hold on;plot(y(min(b+1,num))*[1 1],[1 max(C)],'r')

    figure;
    imagesc(imgOriginal);axis('equal')
    hold on; contour(img_disco,'r','LineWidth',1.5);
    hold on; contour(img_macula,'c','LineWidth',1.5);
    hold on;plot(y(max(b-1,1))*[1 1],[1 Nx],'w')
    hold on;plot(y(min(b+1,num))*[1 1],[1 Nx],'w')

    pause(0.5)
end
