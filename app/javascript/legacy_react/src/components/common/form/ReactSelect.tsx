// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {injectIntl} from 'react-intl';
import {Field, FieldProperties} from "../../../../../../../types/mobx-react-form";
import {InputHTMLAttributes} from "react";
import {action, observable} from "mobx";
import {SelectHTMLAttributes} from "react";
import {ReactInputProps} from "./react_input_props";
import {castToNullIfUndef} from "../../../lib/utils";
import omit from 'lodash/omit';


export interface ReactSelectProps extends ReactInputProps
{
  options?:Array<{id:any, name:string}|{id:any, name:null}>
}

type InputTypes = ReactSelectProps & SelectHTMLAttributes<HTMLSelectElement>

class ReactSelect extends React.Component<InputTypes, {}> {

  constructor(props:InputTypes){
    super(props)
  }


  @action.bound
  componentWillMount(){


    this.updateProps()
  }

  componentWillUnmount(){
  }


  componentDidUpdate(prevProps: Readonly<InputTypes >, prevState: Readonly<{}>): void {
    this.updateProps()
  }

  @action.bound
  updateProps() {
    this.props.field.set('label', castToNullIfUndef(this.props.label))
    this.props.field.set('placeholder', castToNullIfUndef(this.props.placeholder))
  }


  ///Removes the properties we don't want to put into the input element
  @action.bound
  winnowProps() : Omit<InputTypes, 'field'| 'value'|'options'> {
    return omit(this.props, ['field', 'value', 'options']);
  }

  render() {

    return <select {...this.winnowProps()} {...this.props.field.bind()}>
      { this.props.options ? this.props.options.map(option =>
        <option key={option.id} value={option.id}>{option.name}</option>
      ) : this.props.children
       }
    </select>

  }
}

export default observer(ReactSelect)



