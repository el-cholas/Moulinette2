/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_rev_int_tab.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/17 20:43:33 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/17 22:25:01 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

void	ft_rev_int_tab(int *tab, int size)
{
	int	i;
	int	current_int;

	i = 0;
	while (i < size / 2)
	{
		current_int = tab[i];
		tab[i] = tab[size - (i + 1)];
		tab[size - (i + 1)] = current_int;
		i++;
	}
}
