function [ ] = setFBResistorCB( source, callbackdata )

    source.UserData = callbackdata.NewValue.UserData;

end