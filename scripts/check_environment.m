%% Check MATLAB/Simulink project environment
% Reports version, installation, and license availability without changing
% the MATLAB path or installing products.

fprintf("MATLAB release: %s\n", version("-release"));
fprintf("MATLAB version: %s\n\n", version);

requiredProducts = [ ...
    struct("Name", "MATLAB",              "LicenseFeature", "MATLAB")
    struct("Name", "Simulink",            "LicenseFeature", "Simulink")
    struct("Name", "Simscape",            "LicenseFeature", "Simscape")
    struct("Name", "Simscape Electrical", "LicenseFeature", "Power_System_Blocks")
];

installedProducts = string({ver.Name});
allAvailable = true;

fprintf("%-24s %-12s %-12s\n", "Product", "Installed", "Licensed");
fprintf("%-24s %-12s %-12s\n", repmat("-", 1, 24), repmat("-", 1, 12), repmat("-", 1, 12));

for productIndex = 1:numel(requiredProducts)
    product = requiredProducts(productIndex);
    isInstalled = any(installedProducts == product.Name);
    isLicensed = license("test", product.LicenseFeature);
    allAvailable = allAvailable && isInstalled && isLicensed;

    fprintf("%-24s %-12s %-12s\n", product.Name, ...
        yesNo(isInstalled), yesNo(isLicensed));
end

fprintf("\n");
if allAvailable
    fprintf("Environment check passed for the planned project products.\n");
else
    warning(["One or more planned products are missing or unavailable. " ...
        "Review the table before running future Simulink models."]);
end

function text = yesNo(value)
if value
    text = "yes";
else
    text = "no";
end
end
